alias ag=rg
alias d=z
alias git="git --no-pager"
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
alias tf=terraform
alias tmux="TERM=screen-256color tmux"
alias tmuxs='vim ~/.config/tmux/tmux.conf'
alias tt=gotestsum
alias vim='nvim'
alias vimns='vimn ~/.config/nvim/init-b.lua' 
alias vims='vim ~/.config/nvim/init.vim'
alias zshs='vim ~/.zshrc'

goinit() {
    local name=$1
    [[ -d $name ]] || mkdir $name
    cd $name
    go mod init github.com/aweis89/$name
}
