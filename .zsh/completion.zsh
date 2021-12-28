# Completion
# ZSH completion
# Colorize completions using default `ls` colors.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
# Zsh reverse auto-completion
zmodload zsh/complist
bindkey '^[[Z' reverse-menu-complete
# To get new binaries into PATH
zstyle ':completion:*' rehash true
#zstyle ':completion:*' file-sort modification
zstyle ':completion:*' file-sort date
zstyle ':completion:*' menu yes=long select
# Disable prompt disappearing on multi-lines
export COMPLETION_WAITING_DOTS="false"
