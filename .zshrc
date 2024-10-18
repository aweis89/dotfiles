export EDITOR=nvim
export VISUAL=nvim
export GOEXPERIMENT=rangefunc
# export PATH=$HOME/dev/flutter/bin:$PATH
export PATH=$PATH:$HOME/kubectl-plugins
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export FZF_DEFAULT_OPTS='--layout=reverse --color=light  --bind "ctrl-d:page-down,ctrl-u:page-up"'

# Only suggest corrections for commands, not arguments
# setopt CORRECT
# unsetopt CORRECTALL

# Don't print a '%' for partial lines (ones that don't end with a newline)
# https://superuser.com/a/645612/922801
unsetopt PROMPT_SP

# Allow comments in interactive shells
# https://unix.stackexchange.com/q/33994/280976
setopt INTERACTIVE_COMMENTS

export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/dev/flutter/bin:$PATH"
export PATH="$HOME/.krew/bin:$PATH"

# If a command is a directory, cd to it
setopt AUTO_CD

###############################################################################
# History
###############################################################################
HISTFILE=~/.zsh_history
# Max lines kept in a session
HISTSIZE=10000
# Max lines kept in the file
SAVEHIST=10000
# Remove duplicates before unique commands
setopt HIST_EXPIRE_DUPS_FIRST
# Don't add entires that duplicate the previous command
setopt HIST_IGNORE_DUPS
# Remove commands when the first character is a space
setopt HIST_IGNORE_SPACE
# Don't immediately execute commands from history; just fill the edit buffer
setopt HIST_VERIFY
# Share history between shells
setopt SHARE_HISTORY

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

fv() {
  nvim $(fzf)
}

fbranch() {
  git branch | fzf | xargs git checkout
}

###############################################################################
# Completion
###############################################################################
# Smartcase completions:
# capital matches capital; lower matches both lower and capital
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Only regenerate compinit's cache once a day:
# https://htr3n.github.io/2018/07/faster-zsh/
autoload -Uz compinit
if [ $(date +'%j') != $(/usr/bin/stat -f '%Sm' -t '%j' ${ZDOTDIR:-$HOME}/.zcompdump) ]; then
  compinit
else
  compinit -C
fi

###############################################################################
# Prompt
###############################################################################
eval "$(starship init zsh)"

###############################################################################
# Plugins
###############################################################################

# ohmyzsh support
fpath+=~/.cache/oh-my-zsh/completions
ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/oh-my-zsh"
[[ -d $ZSH_CACHE_DIR ]] || (mkdir -p $ZSH_CACHE_DIR && mkdir -p $ZSH_CACHE_DIR/completions)

# set before loading plugins
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Lazy-load antidote and generate the static load file only when needed
zsh_plugins=~/.zsh/.zsh_plugins
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt || ! -e ${zsh_plugins}.zsh ]]; then
  source $(brew --prefix)/opt/antidote/share/antidote/antidote.zsh
  antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
fi
source ${zsh_plugins}.zsh

# mattmc3/zfunctions
export ZFUNCDIR=~/.zsh/functions
fpath=($fpath $HOME/.zsh/functions)

# asdf
. $(brew --prefix asdf)/libexec/asdf.sh

# vi-mode plugin prompt info
export MODE_INDICATOR='%B%F{blue}[<<%f]'
PROMPT="$PROMPT\$(vi_mode_prompt_info)"
RPROMPT="\$(vi_mode_prompt_info)$RPROMPT"

source_present() {
  local -r file="$1"
  test -r $file && . $file
}

source_present $HOME/.zshrc.local
source_present $HOME/.zsh/kubectl.zsh
source_present $HOME/.zsh/alias.zsh

auto_start_tmux() {
  session=${1:-default}
  if test -z "$TMUX"; then
    tmux new-session -ds $session
    tmux attach -t $session
  fi
}

auto_start_tmux

source <(kubebuilder completion zsh)
# source <(flyctl completion zsh)
# source <(regctl completion zsh)
# source <(copilot completion zsh)
# source <(jira completion zsh)
# source <(istioctl completion zsh)

test -f ~/.zfunc/_poetry || {
  mkdir -p ~/.zfunc && poetry completions zsh >~/.zfunc/_poetry
}
fpath+=~/.zfunc
autoload -Uz compinit && compinit

kill-vims() {
  # Loop through each pane in all tmux sessions
  tmux list-panes -a -F '#{pane_id} #{pane_current_command}' | grep vim | awk '{print $1}' | while read pane_id; do
    # Send 'Esc' followed by ':q!' to each Vim session to forcefully close it
    tmux send-keys -t $pane_id Escape ':q!' Enter
  done
}

alias readdir='go run ~/git-project-reader/main.go'

###############################################################################
# Aliases
###############################################################################
alias ls="eza"
alias b="bat"
alias g="git"
alias gd="diff2html -s side"
alias d=z
alias gos=go-search
alias hf=helmfile
alias int='curl -Ss https://google.com'
alias k=kubectl
alias kb=kubebuilder
alias kcg='kubectl config get-contexts'
alias kp=kube-prompt
alias kw='watch kubectl'
alias ll="exa -l --git -h"
alias os=operator-sdk
alias rms='rm -rf ~/.local/share/nvim/swap/*'
alias tmux="TERM=screen-256color tmux"
alias tmuxs='vim ~/.config/tmux/tmux.conf'
alias tt=gotestsum
# alias vim='nvim'
alias v='nvim'
alias vims='vim ~/.config/nvim/lua'
alias zshs='vim ~/.zshrc'
# cd aliases
alias c="cd"
alias c-="cd -"
alias ..="cd .."
alias ...="cd ../.."

alias ku='kustomize'

alias tf=terraform
alias tfa='terraform apply -auto-approve'
alias tfi='terraform init'

# git aliases
alias ggupdate='ga -A && git commit -m update && ggpush'

alias light='~/.config/theme-reactor/change_to.sh light &'
alias dark='~/.config/theme-reactor/change_to.sh dark &'
alias ag=rg

# copilot aliases
alias '??'='unset GITHUB_TOKEN; gh copilot suggest -t shell'
alias 'git?'='unset GITHUB_TOKEN; gh copilot suggest -t git'
alias 'gh?'='unset GITHUB_TOKEN; gh copilot suggest -t gh'
alias 'explain'='unset GITHUB_TOKEN; gh copilot explain'

fzf_vim() {
  if [[ -d "$1" ]]; then
    cd "$1"
    nvim
    cd -
  else
    nvim "$@"
  fi
}

alias vim=fzf_vim

aw() {
  awk "{print \$$1}"
}

ecr-login() {
  aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 805478320556.dkr.ecr.us-west-2.amazonaws.com
}

# source ~/miniforge3/bin/activate  # commented out by conda initialize
export CONDA_DEFAULT_ENV='ai'

# Created by `pipx` on 2023-12-26 02:59:09
export PATH="$PATH:$HOME/.local/bin"
export PATH="/opt/homebrew/anaconda3/bin/:$PATH"

source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/anaconda3/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
if [ $? -eq 0 ]; then
  eval "$__conda_setup"
else
  if [ -f "/opt/homebrew/anaconda3/etc/profile.d/conda.sh" ]; then
    . "/opt/homebrew/anaconda3/etc/profile.d/conda.sh"
  else
    export PATH="/opt/homebrew/anaconda3/bin:$PATH"
  fi
fi
unset __conda_setup
# <<< conda initialize <<<

[[ -s "/Users/aaron/.gvm/scripts/gvm" ]] && source "/Users/aaron/.gvm/scripts/gvm"

k-node-run() {
  local node_name=$1
  shift
  local command=("$@")

  local args_json=$(printf ', "%s"' "${command[@]}")
  args_json="[${args_json:2}]"

  kubectl run -it curl-pod --image=curlimages/curl --overrides="{
    \"apiVersion\": \"v1\",
    \"spec\": {
      \"nodeSelector\": {
        \"kubernetes.io/hostname\": \"${node_name}\"
      },
      \"containers\": [{
        \"name\": \"curl-pod\",
        \"image\": \"curlimages/curl\",
        \"args\": ${args_json}
      }]
    }
  }"
  # kubectl delete pod curl-pod
}

pr-msg() {
  local pr="$(gh pr view --json url,title,number,isDraft)"
  local repo=$(basename -s .git $(git config --get remote.origin.url))
  local title=$(echo $pr | jq -r '.title')
  local number=$(echo $pr | jq -r '.number')
  local url=$(echo $pr | jq -r '.url')
  local isDraft=$(echo $pr | jq -r '.isDraft')
  local msg="[${repo}#${number}: ${title}](${url})"

  if [[ "$isDraft" = "true" ]]; then
    msg=":draft-pr: ${msg}"
  fi

  echo ":pull-request: ${msg} :pray:" | tee >(pbcopy)
}

gcloud-project() {
  projects=$(gcloud projects list)
  selected=$(echo "$projects" | grep -v PROJECT_ID | fzf)
  if [ -n "$selected" ]; then
    project_id=$(echo "$selected" | awk '{print $1}')
    gcloud config set project "$project_id"
    gcloud config get project
  else
    echo "No project selected. Configuration unchanged."
  fi
}
alias gp=gcloud-project

gcloud-update-kubeconfig() {
  cluster=$(gcloud container clusters list | grep -v NAME | fzf)
  if [ -n "$cluster" ]; then
    zone=$(echo "$cluster" | awk '{print $2}')
    name=$(echo "$cluster" | awk '{print $1}')

    set -x
    gcloud container clusters get-credentials "$name" --zone "$zone" "$@"
    set +x
  else
    echo "No cluster selected. Kubeconfig unchanged."
  fi
}
alias guk=gcloud-update-kubeconfig
alias guki='gcloud-update-kubeconfig --internal-ip'

gcloud-account() {
  gcloud auth list --format="table(account)" |
    grep -v ACCOUNT | fzf | xargs gcloud config set account
}

plugin_source() {
  local url_path=$1
  local path_in_repo=$2
  local branch=$3
  local file_name=$(basename "$path_in_repo")
  local local_file_path="$HOME/.${file_name}"

  if [ ! -f "$local_file_path" ]; then
    echo "Downloading ${file_name} plugin..."
    local url="https://raw.githubusercontent.com/${url_path}/${branch}/${path_in_repo}"
    wget "$url" -O "$local_file_path"
  fi
  source "$local_file_path"
}

plugin_source "bonnefoa/kubectl-fzf" "shell/kubectl_fzf.plugin.zsh" "main"
plugin_source "mbhynes/fzf-gcloud" "fzf-gcloud.plugin.zsh" "main"
gcloud-fzf() {
  cmd=$(__gcloud_sel)
  if [[ -n "$cmd" ]]; then
    eval "$cmd"
  fi
}
alias fgc=gcloud-fzf

# Use vi style key bindings instead of emacs
bindkey -v
bindkey '^w' forward-word
bindkey "^r" fzf-history-widget
# zsh-autosuggestions
bindkey '^f' autosuggest-accept

# left arrow
bindkey '^[OD' backward-char

# Keep kubectl_fzf_completion binding
bindkey '^s' kubectl_fzf_completion

# Bind Tab to act like Down arrow in menu selection
bindkey '^I' menu-select
bindkey -M menuselect '^I' down-line-or-history

# Bind Shift-Tab to act like Up arrow in menu selection
bindkey '^[[Z' reverse-menu-select
bindkey -M menuselect '^[[Z' up-line-or-history
