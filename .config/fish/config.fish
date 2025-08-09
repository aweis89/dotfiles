# Disable fish greeting message
set -g fish_greeting

if ! status is-interactive
    return
end

# Add paths
fish_add_path /opt/homebrew/bin
fish_add_path ~/.config/bin
fish_add_path ~/.local/bin
fish_add_path /opt/homebrew/share/google-cloud-sdk/bin

# Auto tmux
if test -z "$TMUX"; and test -z "$NVIM"
    tmux new-session -ds default 2>/dev/null
    tmux attach -t default
end

# Commands to run in interactive sessions can go here
alias k=kubectl
alias ai=aichat
alias k=kubectl
alias kcn=kubens
alias kcu=kubectx
alias vim='nvim'
alias d=z
alias dc=docker-compose
alias kb=kubebuilder
alias kw='watch kubectl'
alias tmux="TERM=screen-256color command tmux"
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
alias zshl='vim ~/.zshrc.local'
alias zshp='vim ~/.zsh/.zsh_plugins.txt'
alias ff='find . -type f -name'
alias fd='find . -type d -name'
alias explain='unset github_token; gh copilot explain'
alias ggroot='cd $(git rev-parse --show-toplevel)'
alias fb='_fzf_git_branches | xargs git checkout'
alias freflog='_fzf_git_lreflogs | xargs git checkout'
alias fishs='vim ~/.config/fish/config.fish'
alias s=signadot

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BREW_PREFIX /opt/homebrew
set -gx ZSH_CACHE_DIR (test -n "$XDG_CACHE_HOME" && echo "$XDG_CACHE_HOME" || echo "$HOME"'/.cache')'/zsh'
set -gx FZF_BASE "$BREW_PREFIX"'/opt/fzf'
set -gx FZF_DEFAULT_OPTS '--tmux 80% --layout=reverse --color=light --bind "tab:down,shift-tab:up,ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" --bind="ctrl-/:change-preview-window(down,50%,border-top|hidden|)"'

function pass_to_aichat_widget
    # Retrieve the current command line input
    set current_input (commandline)
    # Replace the command line with 'aichat -e' followed by the current input
    commandline -r "aichat -e '$current_input'"
    # Execute the new command
    commandline -f execute
end
bind -M insert \co pass_to_aichat_widget

# Abbreviation for aichat
abbr --add ?? 'aichat -e'

function ggmain
    git checkout main 2>/dev/null || git checkout master
    ggpull
end

function goinit
    set -l name $argv[1]
    set -l org $argv[2]
    test -d "$name" || mkdir $name
    cd $name
    go mod init github.com/$org/$name
end

function gomodrename
    set old $argv[1]
    set new $argv[2]
    go mod edit -module $new
    find . -type f -name '*.go' -exec sed -i '' -e 's|'"$old"'|'"$new"'|g' {} \;
end

function gcloud-project
    set projects (gcloud projects list | string collect; or echo)
    set selected (echo "$projects" | grep -v PROJECT_ID | fzf | string collect; or echo)
    if test -n "$selected"
        set project_id (echo "$selected" | awk '{print $1}' | string collect; or echo)
        gcloud config set project "$project_id"
        gcloud config get project
    end
end
alias gp=gcloud-project

function gcloud-update-kubeconfig
    set cluster (gcloud container clusters list | grep -v NAME | fzf | string collect; or echo)
    if test -n "$cluster"
        set zone (echo "$cluster" | awk '{print $2}' | string collect; or echo)
        set name (echo "$cluster" | awk '{print $1}' | string collect; or echo)
        set -x
        gcloud container clusters get-credentials "$name" --zone "$zone" "$argv"
        set +x
    end
end
alias guk=gcloud-update-kubeconfig
alias guki='gcloud-update-kubeconfig --internal-ip'

function gcloud-account
    set account (gcloud auth list --format='table(account)' | grep -v ACCOUNT | fzf | string collect; or echo)
    set -x
    gcloud config set account $account
    set +x
end

function gcloud-fzf
    set cmd (__gcloud_sel | string collect; or echo)
    test -n "$cmd" && eval "$cmd"
end
alias fgc=gcloud-fzf

function pr-msg
    # Retrieve PR data
    set pr (gh pr view --json url,title,number,isDraft)
    # Extract repository name
    set repo (basename -s .git (git config --get remote.origin.url))
    # Parse PR attributes using jq
    set title (echo $pr | jq -r '.title')
    set number (echo $pr | jq -r '.number')
    set url (echo $pr | jq -r '.url')
    set isDraft (echo $pr | jq -r '.isDraft')
    # Construct the message
    set msg "[$repo#$number: $title}($url)"
    if test "$isDraft" = true
        set msg ":draft-pr: $msg"
    end
    # Output the message and copy to clipboard
    echo ":pull-request: $msg :pray:" | tee (pbcopy)
end

bind -M insert \cw forward-word
bind -M insert \cl accept-autosuggestion
bind -M insert \cn accept-autosuggestion
bind -M insert \cj complete
bind -M insert \ck complete
