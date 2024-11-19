# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Skip global compinit
skip_global_compinit=1

if [[ "$PROFILE_STARTUP" == true ]]; then
  zmodload zsh/zprof
fi

# Core environment
export EDITOR=nvim
export VISUAL=nvim
export BREW_PREFIX=/opt/homebrew
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export FZF_BASE="$BREW_PREFIX/opt/fzf"
export FZF_DEFAULT_OPTS='--tmux 90% --layout=reverse --color=light --bind "tab:down,shift-tab:up,ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" --bind="ctrl-/:change-preview-window(down,50%,border-top|hidden|)"'
export ZSH_AUTOSUGGEST_STRATEGY=(history)
export HISTFILE="$ZSH_CACHE_DIR/history"
export HISTSIZE=10000
export SAVEHIST=10000

# Basic path
typeset -U path
path=(
    "$BREW_PREFIX/bin"
    "$BREW_PREFIX/opt/openjdk/bin"
    "$HOME/dev/flutter/bin"
    "$HOME/.krew/bin"
    "$HOME/kubectl-plugins"
    $path
)

# Shell options
setopt \
  INTERACTIVE_COMMENTS \
  AUTO_CD EXTENDED_GLOB \
  HIST_EXPIRE_DUPS_FIRST \
  HIST_IGNORE_DUPS \
  HIST_IGNORE_SPACE \
  HIST_VERIFY SHARE_HISTORY

# vi-mode configuration
bindkey -v

# needs to go before plugin load
zstyle ':completion:*' fzf-search-display true
# Load plugins
() {
    local zsh_plugins=~/.zsh/.zsh_plugins
    if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
        source "$BREW_PREFIX/opt/antidote/share/antidote/antidote.zsh"
        antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
    fi
    source ${zsh_plugins}.zsh
}
# press ctrl-r to repeat completion *without* accepting i.e. reload the completion
# press / to accept the completion and retrigger it
keys=(
    ctrl-r:'repeat-fzf-completion'
    /:accept:'repeat-fzf-completion'
)
zstyle ':completion:*' fzf-completion-keybindings "${keys[@]}"
zstyle ':autocomplete:*' delay 0.3  # don't slow down typing

_evalcache liqoctl completion zsh

# Additional paths
export ZFUNCDIR=~/.zsh/functions
fpath=($fpath $HOME/.zsh/functions ~/.cache/oh-my-zsh/completions ~/.zfunc)

# Custom file widget
_fzf_file_widget() {
    local partial="${LBUFFER##* }"
    
    local result
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        result=$(_fzf_git_files)
    else
        result=$(find . -type f 2>/dev/null | fzf \
          --border-label '📁 Files' \
          --header $'CTRL-O (open in editor)\n\n' \
          --preview 'bat --style=numbers --color=always --line-range :500 {}' \
          --bind "ctrl-o:execute:${EDITOR:-vim} {-1} > /dev/tty" \
        )
    fi
    
    if [[ -n "$result" ]]; then
        result="${result#./}"
        LBUFFER="${LBUFFER%$partial}$result"
    fi
    
    zle reset-prompt
}
zle -N _fzf_file_widget

_fzf_git_files() {
    _fzf_git_check || return
    
    local root query
    root=$(git rev-parse --show-toplevel)
    [[ $root != "$PWD" ]] && query='!../ '
    (
        git -c color.status=$(__fzf_git_color) status --short --no-branch
        git ls-files "$root" |
            grep --color=auto --exclude-dir={.git,.venv,venv} -vxFf \
                <(git status -s | grep '^[^?]' | cut -c4-; echo :) |
            sed 's/^/   /'
    ) | fzf -m --ansi --nth 2..,.. \
        --query "$query" \
        --border-label '📁 Files' \
        --header $'CTRL-G (open in browser) ╱ CTRL-O (open in editor) / CTRL-A (git add)\n\n' \
        --bind "ctrl-g:execute-silent:bash \"$__fzf_git\" file {-1}" \
        --bind "ctrl-o:execute:${EDITOR:-vim} {-1} > /dev/tty" \
        --bind "ctrl-a:execute(git add {-1} && echo 'reload' > /tmp/fzf_reload)+abort" \
        --preview "git diff --no-ext-diff --color=$(__fzf_git_color .) -- {-1} | \
            $(__fzf_git_pager); $(__fzf_git_cat) {-1}" \
        "$@" | cut -c4- | sed 's/.* -> //'

    # Check if we need to reload
    if [[ -f /tmp/fzf_reload ]]; then
      rm /tmp/fzf_reload
      git diff-files --name-status | grep '^M'
      unstaged=$(git diff-files --name-status)
      untracked=$(git ls-files --others --exclude-standard)
      if [ -n "$unstaged" ] || [ -n "$untracked" ]; then
        _fzf_git_files
      fi
    fi
}

multi_fzf_completion() {
    # Trim leading/trailing whitespace from buffer
    local trimmed_buffer="${BUFFER#"${BUFFER%%[![:space:]]*}"}"
    # Extract the first word of the trimmed buffer
    local first_word="${trimmed_buffer%% *}"

    # Check if there's a space after the first word in the original buffer
    if [[ "$BUFFER" =~ [^[:space:]]+[[:space:]] ]]; then
        # Expand the alias if it exists
        local expanded_command
        expanded_command=$(alias "$first_word" 2>/dev/null | sed -E 's/^[^=]+=//; s/^["'\''"]//; s/["'\''"]$//')

        # If there's no alias expansion, use the first word as-is
        [[ -z "$expanded_command" ]] && expanded_command="$first_word"

        # Check if the expanded command starts with "kubectl"
        if [[ "$expanded_command" == kubectl* ]]; then
            # Call kubectl_fzf_completion if it's a kubectl command
            zle kubectl_fzf_completion || zle fzf_completion
            return
        else
            # If there's a space but not kubectl, use fzf-complete
            zle fzf_completion
            return
        fi
    fi
    # If no space after first word, search fzf aliases
    zle _fzf_alias
}
zle -N multi_fzf_completion

_fzf_alias() {
    local selection
    if selection=$(alias |
                       sed -e 's/=/\t/' -e "s/'//g" |
                       column -s '	' -t \
                       | fzf --preview "echo {2..}" --query="$BUFFER" |
                       awk '{ print $1 }'); then
        BUFFER="$selection "
        CURSOR=$#BUFFER
    fi
    zle redisplay
}
zle -N _fzf_alias

# Source additional configs
zsh-defer source "$HOME/.zshrc.local"
zsh-defer source "$HOME/.zsh/kubectl.zsh"
zsh-defer source "$BREW_PREFIX/opt/asdf/libexec/asdf.sh"
zsh-defer source "$BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"

alias k=kubectl
alias kcn=kubens
alias kcu=kubectx
alias ls="eza"
alias vim='nvim'
alias d=z
alias kb=kubebuilder
alias kw='watch kubectl'
alias tmux="TERM=screen-256color tmux"
alias tf=terraform
alias tfa='terraform apply -auto-approve'
alias tfi='terraform init'
alias ag=rg
alias int='curl -ss https://google.com'
alias kb=kubebuilder
alias kw='watch kubectl'
alias rms='rm -rf ~/.local/share/nvim/swap/*'
alias tmuxs='vim ~/.config/tmux/tmux.conf'
alias tt=gotestsum
alias vims='cd ~/.config/nvim/lua && vim'
alias zshs='vim ~/.zshrc'
alias zshp='vim ~/.zsh/.zsh_plugins.txt'
alias ff='find . -type f -name'
alias fd='find . -type d -name'
alias '??'='unset github_token; gh copilot suggest -t shell'
alias 'git?'='unset github_token; gh copilot suggest -t git'
alias 'gh?'='unset github_token; gh copilot suggest -t gh'
alias explain='unset github_token; gh copilot explain'
alias ggroot='cd $(git rev-parse --show-toplevel)'

alias fb='_fzf_git_branches | xargs git checkout'
alias freflog='_fzf_git_lreflogs | xargs git checkout'


ggmain_or_master() {
  git checkout main 2>/dev/null || git checkout master
  ggpull
}
alias ggmain='ggmain_or_master'

goinit() {
  local name=$1
  local org=${2:-aweis89}
  [[ -d $name ]] || mkdir $name
  cd $name
  go mod init github.com/$org/$name
}

gomodrename() {
    old=$1
    new=$2
    go mod edit -module $new
    find . -type f -name '*.go' \
        -exec sed -i '' -e "s|${old}|${new}|g" {} \;
}

gcloud-project() {
    projects=$(gcloud projects list)
    selected=$(echo "$projects" | grep -v PROJECT_ID | fzf)
    if [[ -n "$selected" ]]; then
        project_id=$(echo "$selected" | awk '{print $1}')
        gcloud config set project "$project_id"
        gcloud config get project
    fi
}
alias gp=gcloud-project

gcloud-update-kubeconfig() {
    cluster=$(gcloud container clusters list | grep -v NAME | fzf)
    if [[ -n "$cluster" ]]; then
        zone=$(echo "$cluster" | awk '{print $2}')
        name=$(echo "$cluster" | awk '{print $1}')
        set -x
        gcloud container clusters get-credentials "$name" --zone "$zone" "$@"
        set +x
    fi
}
alias guk=gcloud-update-kubeconfig
alias guki='gcloud-update-kubeconfig --internal-ip'

_gcloud_account() {
    account=$(gcloud auth list --format="table(account)" | grep -v ACCOUNT | fzf)
    set -x
    gcloud config set account $account
    set +x
}
alias gcloud-account=_gcloud_account

gcloud-fzf() {
    cmd=$(__gcloud_sel)
    [[ -n "$cmd" ]] && eval "$cmd"
}
alias fgc=gcloud-fzf

# Utility Functions
slack-pr-msg() {
    local pr="$(gh pr view --json url,title,number,isDraft)"
    local repo=$(basename -s .git $(git config --get remote.origin.url))
    local title=$(echo $pr | jq -r '.title')
    local number=$(echo $pr | jq -r '.number')
    local url=$(echo $pr | jq -r '.url')
    local isDraft=$(echo $pr | jq -r '.isDraft')
    local msg="[${repo}#${number}: ${title}](${url})"
    
    [[ "$isDraft" = "true" ]] && msg=":draft-pr: ${msg}"
    echo ":pull-request: ${msg} :pray:" | tee >(pbcopy)
}
alias pr-msg=slack-pr-msg

llm() {
    go run ~/p/llm-agent/ "$@" | bat --language=Markdown
}

# Lazy completions
kubebuilder() {
    unfunction "$0"
    source <(kubebuilder completion zsh)
    $0 "$@"
}

temporal() {
    unfunction "$0"
    source <(temporal completion zsh)
    $0 "$@"
}

# Auto tmux
() {
    [[ -z "$TMUX" ]] && {
        tmux new-session -ds default
        tmux attach -t default
    }
}

bindkey '^w' forward-word
bindkey '^r' fzf-history-widget
bindkey '^l' autosuggest-accept
bindkey '^[OD' backward-char
bindkey '^s' multi_fzf_completion
bindkey '^F' _fzf_file_widget
bindkey '^g' fzf-gcloud-widget

bindkey '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select
bindkey -M menuselect '^I' menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete

bindkey '^J' menu-select
bindkey '^K' menu-select
bindkey -M menuselect '^J' menu-complete
bindkey -M menuselect '^K' reverse-menu-complete

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ "$PROFILE_STARTUP" == true ]]; then
    zprof
fi
