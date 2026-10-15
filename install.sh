#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
backup_suffix="$(date +%Y%m%d-%H%M%S)"

link_config() {
    local source="$1"
    local target="$2"

    mkdir -p -- "$(dirname -- "$target")"

    if [[ -L "$target" && "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
        return
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        mv -- "$target" "$target.backup-$backup_suffix"
        printf 'Backed up %s to %s\n' "$target" "$target.backup-$backup_suffix"
    fi

    ln -s -- "$source" "$target"
    printf 'Linked %s -> %s\n' "$target" "$source"
}

link_config "$repo_dir/niri/config.kdl" "$config_home/niri/config.kdl"
link_config "$repo_dir/noctalia/config.toml" "$config_home/noctalia/config.toml"
link_config "$repo_dir/noctalia/gamer-mode.toml" "$config_home/noctalia/gamer-mode.toml"

systemd_user_home="$config_home/systemd/user"
link_config \
    "$repo_dir/systemd/user/niri-lg-display-reset.service" \
    "$systemd_user_home/niri-lg-display-reset.service"

systemctl --user daemon-reload
systemctl --user enable --now niri-lg-display-reset.service

printf 'Configuration links are installed.\n'
