# Niri + Noctalia configuration

Version-controlled configuration for Niri and Noctalia Shell on CachyOS.

## Managed files

- `niri/config.kdl` → `~/.config/niri/config.kdl`
- `noctalia/config.toml` → `~/.config/noctalia/config.toml`
- `noctalia/gamer-mode.toml` → `~/.config/noctalia/gamer-mode.toml`
- `ghostty/config` → `~/.config/ghostty/config`
- `zsh/.zshrc` → `~/.zshrc`
- `starship/starship.toml` → `~/.config/starship.toml`
- `wireplumber/wireplumber.conf.d/50-spotify-follow-default.conf` →
  `~/.config/wireplumber/wireplumber.conf.d/50-spotify-follow-default.conf`

The files in this repository are the source of truth. `install.sh` creates the
live configuration symlinks and backs up any existing regular files before
replacing them.

## Install

```sh
./install.sh
```

After changing the Niri configuration, validate it with:

```sh
niri validate --config "$HOME/.config/niri/config.kdl"
```

To refresh the LG DisplayPort link after a suspend/resume flicker:

```sh
./scripts/reset-lg-display.sh
```

The display reset watcher is installed as a user systemd service. It runs once
after login and again after each suspend/resume cycle:

```sh
systemctl --user status niri-lg-display-reset.service
```

The Niri output names and display settings are specific to the current
machine. Review the `output` blocks before using this configuration elsewhere.

Spotify follows the system default audio output (like VLC) because of the
WirePlumber rule above. After `./install.sh`, restart WirePlumber once so it
loads the rule: `systemctl --user restart wireplumber`. Then move any
already-playing Spotify stream once in the mixer. Check the rule offline with:

```sh
./scripts/check-spotify-follow-default.sh
```
