#!/opt/homebrew/bin/zsh

# Auto tmux
[[ -z "$TMUX" ]] && [[ -z "$NVIM" ]] && {
    tmux new-session -ds default
    tmux attach -t default
}

emulate zsh -c "$(direnv export zsh)"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

emulate zsh -c "$(direnv hook zsh)"

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

fzf_default_opts=(
  --multi
  --layout=reverse 
  --color=light
  "--bind='ctrl-p:toggle-preview'"
  "--bind='ctrl-s:toggle+down'"
  "--bind='ctrl-y:select-all'"
  "--bind='ctrl-d:half-page-down,ctrl-u:half-page-up'"
  "--bind='ctrl-f:preview-half-page-down,ctrl-b:preview-half-page-up'"
  "--bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)'"
)
export FZF_DEFAULT_OPTS="${fzf_default_opts[*]}"

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
  INC_APPEND_HISTORY \
  SHARE_HISTORY \
  INTERACTIVE_COMMENTS \
  HIST_EXPIRE_DUPS_FIRST \
  HIST_IGNORE_DUPS \
  HIST_IGNORE_SPACE \
  HIST_VERIFY SHARE_HISTORY

# Line wrapping for pane resizing
setopt \
  PROMPT_SP \
  PROMPT_CR \
  PROMPT_SUBST

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
zstyle ':autocomplete:*' delay 0.5  # don't slow down typing
zstyle ':autocomplete:*' async on

_evalcache zoxide init zsh

# Additional paths
export ZFUNCDIR=~/.zsh/functions
fpath=($fpath $HOME/.zsh/functions ~/.cache/oh-my-zsh/completions ~/.zfunc)

# Custom file widget
_fzf_file_widget() {
    local lbuffer="${LBUFFER##* }"
    # Expand any environment variables on command line
    local partial=$(eval echo "$lbuffer")
    local query="$partial"
    local dir=""
    # If partial contains / and ends with /, extract dir and query
    if [[ "$partial" =~ .*/$ ]]; then
        dir="${partial%/*}"
        query=""
    # If partial contains / but doesn't end with /, extract dir and last component
    elif [[ "$partial" =~ .*/.* ]]; then
        dir="${partial%/*}"
        query="${partial##*/}" # this isn't getting set correctly
    fi
    # Change to directory if specified
    local orig_dir=$(pwd)
    if [[ -n "$dir" ]]; then
        cd "$dir" 2>/dev/null || return
    fi
    
    local result
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        result=$(_fzf_git_files)
    else
        result=$(find . -type f 2>/dev/null | fzf \
          --border-label '📁 Files' \
          --header $'CTRL-O (open in editor)\n\n' \
          --preview 'bat --style=numbers --color=always --line-range :500 {}' \
          --bind "ctrl-o:execute:${EDITOR:-vim} {-1} > /dev/tty" \
          --query "$query"
        )
    fi
    
    if [[ -n "$result" ]]; then
        result="${result#./}"
        LBUFFER="${LBUFFER%$partial}$result"
    fi

    # Change back to original directory
    cd "$orig_dir"
    
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

    # Check if we need to reload after git add
    if [[ -f /tmp/fzf_reload ]]; then
      rm /tmp/fzf_reload
      git diff-files --name-status | grep '^M'
      unstaged=$(git diff-files --name-status)
      untracked=$(git ls-files --others --exclude-standard)
      if [ -n "$unstaged" ] || [ -n "$untracked" ]; then
        _fzf_git_files
      else
        exec </dev/tty >/dev/tty 2>/dev/tty
        git commit -v && ggpush
      fi
    fi
}

multi_fzf_completion() {
    # Helper function to expand aliases
    expand_alias() {
        local cmd="$1"
        alias "$cmd" 2>/dev/null | sed -E 's/^[^=]+=//; s/^["'\''"]//; s/["'\''"]$//'
    }

    # Helper function to check if buffer has space after first word
    has_space_after_first_word() {
        [[ "$BUFFER" =~ [^[:space:]]+[[:space:]] ]]
    }

    # Trim leading/trailing whitespace and get first word
    local trimmed_buffer="${BUFFER#"${BUFFER%%[![:space:]]_}"}"
    local first_word="${trimmed_buffer%% _}"

    if has_space_after_first_word; then
        # Get expanded command or use first_word if no alias exists
        local expanded_command
        expanded_command=$(expand_alias "$first_word")
        : ${expanded_command:=$first_word}

        # Handle kubectl commands specially
        if [[ "$expanded_command" == kubectl* ]]; then
            zle kubectl_fzf_completion
            return
        fi

        # Default to regular fzf completion
        zle fzf_completion
        return
    fi

    # No space after first word, use alias completion
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

alias aig='aichat --model "gemini:gemini-exp-1206"'
alias ais='aichat --model "claude:claude-3-5-sonnet-latest"'
alias ai1='aichat --model "openai:o1-preview"'

alias ai=aichat
alias '??'='aichat -e'

alias k=kubectl
alias kcn=kubens
alias kcu=kubectx
alias vim='nvim'
alias c=clear
alias d=z
alias dc=docker-compose
alias kb=kubebuilder
alias kw='watch kubectl'
alias tmux="TERM=screen-256color tmux"
alias tf=terraform
alias tfa='terraform apply -auto-approve'
alias tfi='terraform init'
alias ag=rg
alias rgh="rg --hidden --glob '!**/.git/**'"
alias int='curl -ss https://google.com'
alias kb=kubebuilder
alias kw='watch kubectl'
alias rms='rm -rf ~/.local/state/nvim/swap/*'
alias tmuxs='vim ~/.config/tmux/tmux.conf'
alias tt=gotestsum
alias vims='cd ~/.config/nvim/lua && vim'
alias kittys='vim ~/.config/kitty/kitty.conf'
alias zshs='vim ~/.zshrc'
alias zshl='vim ~/.zshrc.local'
alias zshp='vim ~/.zsh/.zsh_plugins.txt'
alias ff='find . -type f -name'
alias fd='find . -type d -name'
alias explain='unset github_token; gh copilot explain'
alias ggroot='cd $(git rev-parse --show-toplevel)'

alias fb='_fzf_git_branches | xargs git checkout'
alias freflog='_fzf_git_lreflogs | xargs git checkout'
alias fishs='vim ~/.config/fish/config.fish'

pr-review() {
  set -e

  # Extract PR number from argument
  local pr="${1##*/}"
  if ! [[ "$pr" =~ ^[0-9]+$ ]]; then
    echo "Invalid PR number or URL format"
    return 1
  fi

  # Store current branch
  local orig_branch
  orig_branch=$(git branch --show-current) || return 1

  # Get base branch name
  local base
  base=$(gh pr view "$pr" --json baseRefName --jq '.baseRefName') || return 1

  # Fetch, checkout and diff
  git fetch origin "$base"

  # Check if PR is already merged
  if gh pr view "$pr" --json state --jq '.state' | grep -q "MERGED"; then
    echo "PR $pr is already merged"
    return 0
  fi
  
  gh pr checkout "$pr"
  git diff "origin/$base"

  # Prompt for approval
  local user_input
  printf "Approve (y/n)? "
  read -r user_input

  if [[ "$user_input" == "y" ]]; then
    if gh pr review --approve; then
      echo "PR $pr approved"
    fi
  fi

  # Return to original branch
  git checkout "$orig_branch"
  set +e
}

delta() {
  set +x
  local mode=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
  if [[ "$mode" == "Dark" ]];then
    command delta --dark "$@"
    return
  fi
  command delta --light "$@"
}

rg() {
  command rg --json -C 2 "$@" | delta
}

kubectl() {
  if [[ "$@" == *"-o yaml"* ]]; then
    command kubectl "$@" | bat --language yaml --style plain
  else
    command kubectl "$@"
  fi
}

helm() {
  if [[ "$@" == *"template"* ]]; then
    command helm "$@" | bat --language yaml --style plain
  else
    command helm "$@"
  fi
}

p() {
  set -x
  go run $HOME/dotfiles/bin/perplexity.go "$@"
}

aider() {
  opts=(--show-diffs)
  local mode=$(defaults read -g AppleInterfaceStyle 2>/dev/null)
  [[ "$mode" == "Dark" ]] && opts+=(--dark-mode)
  # ~/p/aider/venv/bin/aider "${opts[@]}" "$@"
  command aider "${opts[@]}" "$@"
}
compdef aider=_aider

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

pass-to-aichat-widget() {
    BUFFER="aichat -e $BUFFER"
    zle accept-line
}
zle -N pass-to-aichat-widget

bindkey '^o' pass-to-aichat-widget
bindkey '^w' forward-word
bindkey '^r' fzf-history-widget
bindkey '^l' autosuggest-accept
bindkey '^[OD' backward-char
bindkey '^s' multi_fzf_completion
bindkey '^F' _fzf_file_widget
bindkey '^b' _fzf_file_widget
bindkey '^g' fzf-gcloud-widget

bindkey '^I' menu-select
bindkey "$terminfo[kcbt]" menu-select
bindkey -M menuselect '^I' menu-complete
bindkey -M menuselect "$terminfo[kcbt]" reverse-menu-complete

bindkey '^J' menu-select
bindkey -M menuselect '^J' menu-complete
bindkey -M menuselect '^K' reverse-menu-complete

bindkey '^o' zsh_llm_suggestions_openai # Ctrl + O to have OpenAI suggest a command given a English description

# argc-completions
export ARGC_COMPLETIONS_ROOT="$HOME/.local/argc-completions"
if [[ ! -d "$ARGC_COMPLETIONS_ROOT" ]]; then
  mkdir -p $ARGC_COMPLETIONS_ROOT
  git clone https://github.com/sigoden/argc-completions.git $ARGC_COMPLETIONS_ROOT
  $ARGC_COMPLETIONS_ROOT/scripts/download-tools.sh
  $ARGC_COMPLETIONS_ROOT/scripts/setup-shell.sh zsh
fi
export ARGC_COMPLETIONS_PATH="$ARGC_COMPLETIONS_ROOT/completions/macos:$ARGC_COMPLETIONS_ROOT/completions"
export PATH="$ARGC_COMPLETIONS_ROOT/bin:$PATH"
# To add completions for only the specified command, modify next line e.g. argc_scripts=( cargo git )
argc_scripts=( $(ls -p -1 "$ARGC_COMPLETIONS_ROOT/completions/macos" "$ARGC_COMPLETIONS_ROOT/completions" | sed -n 's/\.sh$//p') )
source <(argc --argc-completions zsh $argc_scripts)

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ "$PROFILE_STARTUP" == true ]]; then
    zprof
fi

# Created by `pipx` on 2024-11-26 01:38:49
export PATH="$PATH:/Users/aaron.weisberg/.local/bin"
