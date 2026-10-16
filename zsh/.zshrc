# Interactive Zsh configuration for this machine.
# Starship is used instead of CachyOS's Powerlevel10k default so the prompt
# stays consistent with Fish and John's shell setup.

export LANG="${LANG:-en_US.UTF-8}"
export COLORTERM="${COLORTERM:-truecolor}"

# Keep local tools available in interactive shells.
typeset -U path PATH
path=(
    "$HOME/.opencode/bin"
    "$HOME/.local/bin"
    $path
)
export PATH

# History is kept under XDG_CONFIG_HOME and shared between Zsh sessions.
HISTFILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000
mkdir -p -- "${HISTFILE:h}"

setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_BY_COPY
setopt SHARE_HISTORY

# Completion, including the Arch extra completion definitions.
fpath=(/usr/share/zsh/site-functions $fpath)
autoload -Uz compinit
compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select

# Use Emacs-style editing keys and make common terminal sequences predictable.
bindkey -e
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# History-based suggestions and syntax highlighting.
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'

# Search history with Atuin and use it as the autosuggestion strategy.
source <(atuin init zsh)

# Interactive navigation and project environment integration.
eval "$(zoxide init zsh)"
eval "$(direnv hook zsh)"
source <(fzf --zsh)

# Convenient file and directory navigation.
function y() {
    local tmp cwd
    tmp="$(mktemp -t 'yazi-cwd.XXXXXX')"
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(<"$tmp")" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
        builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}

# Everyday aliases.
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --group-directories-first'
alias la='eza -a --icons=auto --group-directories-first'
alias lla='eza -la --icons=auto --group-directories-first'
alias lt='eza --tree --icons=auto'
alias cat='bat --paging=never'
alias lg='lazygit'
alias ld='lazydocker'
alias c='clear'

# Starship must be initialized after the shell integrations that add hooks.
eval "$(starship init zsh)"

# Syntax highlighting must be loaded last.
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
