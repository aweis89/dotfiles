export EDITOR=nvim
export VISUAL=nvim

# Only suggest corrections for commands, not arguments
setopt CORRECT
unsetopt CORRECTALL

# Don't print a '%' for partial lines (ones that don't end with a newline)
# https://superuser.com/a/645612/922801
unsetopt PROMPT_SP

# Allow comments in interactive shells
# https://unix.stackexchange.com/q/33994/280976
setopt INTERACTIVE_COMMENTS

export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/dev/flutter/bin:$PATH"
export PATH="$HOME/.krew/bin:$PATH"

export AWS_PROFILE=labs

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
    [[ -d $name ]] || mkdir $name
    cd $name
    go mod init github.com/aweis89/$name
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

# Use vi style key bindings instead of emacs
bindkey -v
bindkey '^w' forward-word
bindkey "^r" fzf-history-widget
# zsh-autosuggestions
bindkey '^f' autosuggest-accept

# zsh-autocomplete
bindkey '\t' menu-select "${terminfo[kcbt]}" menu-select
bindkey -M menuselect '\t' menu-complete "${terminfo[kcbt]}" reverse-menu-complete
# make enter submit direct from menu
# bindkey -M menuselect '\r' .accept-line

# left arrow
bindkey '^[OD' backward-char

which copilot >/dev/null || brew install aws/tap/copilot-cli
source <(eksctl completion zsh)
source <(kubebuilder completion zsh)
source <(flyctl completion zsh)
source <(regctl completion zsh)
source <(copilot completion zsh)
source $(pack completion --shell zsh)

test -f ~/.zfunc/_poetry || { \
  mkdir -p ~/.zfunc && poetry completions zsh > ~/.zfunc/_poetry
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

###############################################################################
# Aliases
###############################################################################
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
alias vim='nvim'
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

aw() {
    awk "{print \$$1}"
}

ecr-login() {
  aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin  805478320556.dkr.ecr.us-west-2.amazonaws.com
}

source ~/miniforge3/bin/activate
export CONDA_DEFAULT_ENV='tensorflow_ARM'

# Created by `pipx` on 2023-12-26 02:59:09
export PATH="$PATH:/Users/aaron/.local/bin"
export PATH="/opt/homebrew/anaconda3/bin/:$PATH"

source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
