bindkey "^R" fzf-history-widget
bindkey "^K" kill-line
bindkey "^N" insert-last-word
bindkey "^P" history-search-backward
bindkey "^Q" push-line-or-edit
bindkey "^Y" accept-and-hold
bindkey '^D' clear-screen
bindkey '^F' autosuggest-accept
bindkey '^J' down-history
bindkey '^K' up-history
bindkey '^L' end-of-line
bindkey '^H' beginning-of-line
bindkey -s "^T" "^[Isudo ^[A" # "t" for "toughguy"

# vi mode
bindkey -v
bindkey -M viins 'jj' vi-cmd-mode
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^w' backward-kill-word

#bindkey '^?' backward-delete-char
#bindkey '^h' backward-delete-char
#bindkey '^w' backward-kill-word

## Up arrow:
#bindkey '\e[A' up-line-or-search
#bindkey '\eOA' up-line-or-search
## up-line-or-search:  Open history menu.
## up-line-or-history: Cycle to previous history line.
#
## Down arrow:
#bindkey '\e[B' down-line-or-select
#bindkey '\eOB' down-line-or-select
#
## Control-Space:
#bindkey '\0' list-expand
#bindkey -M menuselect '\r' .accept-line
