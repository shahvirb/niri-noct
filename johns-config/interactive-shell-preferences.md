# John’s Interactive Shell Preferences

John’s terminal workflow is centered on **Zsh**, managed through Nix/Home Manager.

## Shell

- Uses a custom wrapped Zsh package named `jsl-zsh`.
- Uses `jsl-zsh` as the login shell on NixOS and as the Home Manager Zsh package.
- Keeps Zsh configuration under `$XDG_CONFIG_HOME/zsh`.
- Sets `LANG=en_US.UTF-8`, enables true-color support, and identifies the shell as Zsh for devenv.

## Interactive features

- Completion is enabled, including extra completions and case-insensitive matching.
- History-based and completion-based autosuggestions are enabled.
- History is stored in `$XDG_CONFIG_HOME/zsh/.zsh_history`, shared between sessions, appended, expanded, and configured to ignore duplicates and commands beginning with a space.
- `fzf`, `atuin`, `zoxide`, and Starship are integrated.
- Common Home, End, Delete, and Ctrl+Arrow escape sequences are normalized for terminal compatibility.

## Prompt

Starship uses the Nerd Font and Catppuccin Powerline presets with a Catppuccin Mocha palette. The prompt shows information such as:

- Hostname, including an SSH indicator
- Current directory
- Git branch and status
- Command duration
- NixOS symbol

TTY sessions use a simpler ASCII-oriented Starship prompt.

## Aliases and shell tools

Configured aliases include:

```text
ls  -> eza
ll  -> eza -l
la  -> eza -a
lt  -> eza --tree
lla -> eza -la
ds  -> gdu -i /snap /
```

The shell-tools bundle adds utilities including `fd`, `ripgrep`, `jq`, `yq`, `curl`, `wget`, `direnv`, `fzf`, `zoxide`, `bat`, `delta`, `eza`, `gdu`, `lazygit`, `lazydocker`, `lf`, `yazi`, and related tools.

## Ghostty

Ghostty starts the custom shell directly:

```nix
command = "TERM=xterm-256color .../jsl-zsh";
```

Ghostty also enables Zsh integration and uses Hack Nerd Font with the Catppuccin Mocha theme.

## Source files

- `modules/programs/zsh.nix`
- `modules/features/shell-tools/default.nix`
- `modules/features/shell-tools/starship.nix`
- `modules/programs/ghostty.nix`
