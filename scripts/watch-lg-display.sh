#!/usr/bin/env bash
set -uo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
reset_script="$script_dir/reset-lg-display.sh"

log() {
    printf 'watch-lg-display: %s\n' "$*"
}

find_niri_socket() {
    local socket

    socket=$(
        find "${XDG_RUNTIME_DIR:?}" \
            -maxdepth 1 \
            -type s \
            -name 'niri.*.sock' \
            -printf '%T@ %p\n' 2>/dev/null |
            sort -nr |
            sed -n '1s/^[^ ]* //p'
    )

    if [[ -z "$socket" ]]; then
        log 'could not find the Niri socket.' >&2
        return 1
    fi

    export NIRI_SOCKET="$socket"
}

run_reset() {
    if "$reset_script"; then
        log 'LG display link refresh completed.'
    else
        log 'LG display link refresh failed; continuing to watch for the next resume.' >&2
    fi
}

run_reset_with_retries() {
    local attempt

    for attempt in 1 2 3; do
        if find_niri_socket && run_reset; then
            return 0
        fi

        if (( attempt < 3 )); then
            log "Retrying LG display link refresh (attempt $((attempt + 1))/3)."
            sleep 2
        fi
    done

    return 1
}

if [[ ! -x "$reset_script" ]]; then
    log "reset script is missing or not executable: $reset_script" >&2
    exit 1
fi

command -v gdbus >/dev/null 2>&1 || {
    log 'gdbus is not installed.' >&2
    exit 1
}

# Give Niri time to finish creating its outputs after graphical login.
sleep 2
run_reset_with_retries || true

log 'Watching logind for suspend/resume events.'

# logind emits PrepareForSleep(false) after the system has resumed.
while IFS= read -r line; do
    if [[ "$line" == *'PrepareForSleep (false,'* ]]; then
        # Wait for the compositor and monitor link to settle before resetting.
        sleep 2
        run_reset_with_retries || true
    fi
done < <(
    gdbus monitor \
        --system \
        --dest org.freedesktop.login1 \
        --object-path /org/freedesktop/login1
)

# Reaching here means the D-Bus monitor exited unexpectedly. Let systemd restart us.
log 'D-Bus monitor exited unexpectedly.' >&2
exit 1
