#!/usr/bin/env bash
set -euo pipefail

# Refresh the LG Ultra HD's DisplayPort link by briefly switching it to 30 Hz
# and then restoring the normal 59.997 Hz mode.

readonly LG_OUTPUT="LG Electronics LG Ultra HD 0x00022665"
readonly LG_30HZ_MODE="3840x2160@30.000"
readonly LG_60HZ_MODE="3840x2160@59.997"
readonly DWELL_SECONDS=1

restore_pending=0

fail() {
    printf 'reset-lg-display: %s\n' "$*" >&2
    exit 1
}

set_lg_mode() {
    niri msg output "$LG_OUTPUT" mode "$1"
}

restore_on_exit() {
    local status=$?
    trap - EXIT

    if (( restore_pending )); then
        printf 'Restoring LG to %s...\n' "$LG_60HZ_MODE" >&2
        if set_lg_mode "$LG_60HZ_MODE"; then
            printf 'LG restored to 59.997 Hz.\n' >&2
        else
            printf 'Could not restore the LG to 59.997 Hz.\n' >&2
            (( status == 0 )) && status=1
        fi
    fi

    exit "$status"
}

command -v niri >/dev/null 2>&1 || fail 'niri is not installed.'

if ! niri msg outputs | grep -Fq "Output \"$LG_OUTPUT\""; then
    fail "LG output was not found: $LG_OUTPUT"
fi

trap restore_on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

restore_pending=1
printf 'Switching LG to %s for %s second...\n' "$LG_30HZ_MODE" "$DWELL_SECONDS"
set_lg_mode "$LG_30HZ_MODE"
sleep "$DWELL_SECONDS"

printf 'Restoring LG to %s...\n' "$LG_60HZ_MODE"
set_lg_mode "$LG_60HZ_MODE"
restore_pending=0
trap - EXIT INT TERM
printf 'LG display link refresh complete.\n'
