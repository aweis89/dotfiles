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
export FZF_DEFAULT_OPTS='--layout=reverse --color=light --bind "tab:down,shift-tab:up,ctrl-d:page-down,ctrl-u:page-up"'
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)
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

# needs to go after plugin load
zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

# Initialize starship prompt
_evalcache starship init zsh

# Additional paths
export ZFUNCDIR=~/.zsh/functions
fpath=($fpath $HOME/.zsh/functions ~/.cache/oh-my-zsh/completions ~/.zfunc)

# Custom file widget
_fzf_file_widget() {
    local partial="${LBUFFER##* }"
    local search_dir="."
    
    if [[ -n "$partial" ]]; then
        if [[ -d "$partial" ]]; then
            search_dir="$partial"
        elif [[ -d "$(dirname "$partial")" ]]; then
            search_dir="$(dirname "$partial")"
        fi
    fi
    
    local result=$(cd "$search_dir" 2>/dev/null && find . -type f 2>/dev/null | fzf)
    
    if [[ -n "$result" ]]; then
        result="${result#./}"
        LBUFFER="${LBUFFER%$partial}$search_dir/$result"
    fi
    
    zle reset-prompt
}
zle -N _fzf_file_widget

_kubectl_or_alias_fzf() {
    # Extract the first word of the buffer
    local first_word="${BUFFER%% *}"

    # Check if there's a space after the first word
    if [[ "$BUFFER" =~ ^[^[:space:]]+[[:space:]] ]]; then
        # Expand the alias if it exists
        local expanded_command
        expanded_command=$(alias "$first_word" 2>/dev/null | sed -E 's/^[^=]+=//; s/^["'\''"]//; s/["'\''"]$//')

        # If there's no alias expansion, use the first word as-is
        [[ -z "$expanded_command" ]] && expanded_command="$first_word"

        # Check if the expanded command starts with "kubectl"
        if [[ "$expanded_command" == kubectl* ]]; then
            # Call kubectl_fzf_completion if it's a kubectl command
            zle kubectl_fzf_completion
            return
        fi
    fi

    # If no space after first word or not kubectl, search fzf aliases
    zle _fzf_alias
}
zle -N _kubectl_or_alias_fzf

_fzf_alias() {
    FZF_ALIAS_OPTS=${FZF_ALIAS_OPTS:-"--preview-window up:3:hidden:wrap"}
    local selection
    if selection=$(alias |
                       sed 's/=/\t/' |
                       column -s '	' -t |
                       FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_ALIAS_OPTS" \
                         fzf --preview "echo {2..}" --query="$BUFFER" |
                       awk '{ print $1 }'); then
        BUFFER="$selection "
        CURSOR=$#BUFFER
    fi
    zle redisplay
}
zle -N _fzf_alias

bindkey '^w' forward-word
bindkey '^r' fzf-history-widget
bindkey '^l' autosuggest-accept
bindkey '^[OD' backward-char
bindkey '^s' _kubectl_or_alias_fzf
bindkey '^I' fzf_completion
bindkey '^[[Z' reverse-menu-select
bindkey -M menuselect '^[[Z' up-line-or-history
bindkey '^F' _fzf_file_widget
bindkey '^g' fzf-gcloud-widget

# Source additional configs
zsh-defer source "$HOME/.zshrc.local"
zsh-defer source "$HOME/.zsh/kubectl.zsh"
zsh-defer source "$BREW_PREFIX/opt/asdf/libexec/asdf.sh"
zsh-defer source "$BREW_PREFIX/share/google-cloud-sdk/completion.zsh.inc"

alias k=kubectl
alias kcn=kubens
alias kcu=kubectx
alias ls="eza"
alias g="git"
alias v='nvim'
alias vim='nvim'
alias c="cd"
alias ..="cd .."
alias ...="cd ../.."
alias b="bat"
alias gd="diff2html -s side"
alias d=z
alias gos=go-search
alias hf=helmfile
alias kb=kubebuilder
alias kcg='kubectl config get-contexts'
alias kw='watch kubectl'
alias ll="eza -l --git -h"
alias os=operator-sdk
alias tmux="TERM=screen-256color tmux"
alias tf=terraform
alias tfa='terraform apply -auto-approve'
alias tfi='terraform init'
alias light='~/.config/theme-reactor/change_to.sh light &'
alias dark='~/.config/theme-reactor/change_to.sh dark &'
alias ag=rg
alias guk=gcloud-update-kubeconfig
alias guki='gcloud-update-kubeconfig --internal-ip'
alias fgc=gcloud-fzf
alias explain='unset GITHUB_TOKEN; gh copilot explain'
alias int='curl -Ss https://google.com'
alias kb=kubebuilder
alias kw='watch kubectl'
alias rms='rm -rf ~/.local/share/nvim/swap/*'
alias tmuxs='vim ~/.config/tmux/tmux.conf'
alias tt=gotestsum
alias vims='cd ~/.config/nvim/lua && vim'
alias zshs='vim ~/.zshrc'
alias ff='find . -type f -name'
alias fd='find . -type d -name'
alias '??'='unset GITHUB_TOKEN; gh copilot suggest -t shell'
alias 'git?'='unset GITHUB_TOKEN; gh copilot suggest -t git'
alias 'gh?'='unset GITHUB_TOKEN; gh copilot suggest -t gh'

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

fbranch() {
    git branch | fzf | xargs git checkout
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

gcloud-account() {
    gcloud auth list --format="table(account)" |
        grep -v ACCOUNT | fzf | xargs gcloud config set account
}

gcloud-fzf() {
    cmd=$(__gcloud_sel)
    [[ -n "$cmd" ]] && eval "$cmd"
}

# Utility Functions
pr-msg() {
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

if [[ "$PROFILE_STARTUP" == true ]]; then
    zprof
fi
