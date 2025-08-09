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

alias cat="bat --theme auto:system --theme-dark default --theme-light GitHub"
alias d=z
alias k=kubectl
alias tmux='TERM=screen-256color command tmux'
alias vim=nvim

# Commands to run in interactive sessions can go here
abbr -a -- ai aichat
abbr -a -- kcn kubens
abbr -a -- kcu kubectx
abbr -a -- dc docker-compose
abbr -a -- kb kubebuilder
abbr -a -- kw 'watch kubectl'
abbr -a -- tf terraform
abbr -a -- tfa 'terraform apply -auto-approve'
abbr -a -- tfi 'terraform init'
abbr -a -- int 'curl -ss https://google.com'
abbr -a -- rms 'rm -rf ~/.local/share/nvim/swap/*'
abbr -a -- tmuxs 'vim ~/.config/tmux/tmux.conf'
abbr -a -- tt gotestsum
abbr -a -- vims 'cd ~/.config/nvim/lua && vim'
abbr -a -- zshs 'vim ~/.zshrc'
abbr -a -- zshl 'vim ~/.zshrc.local'
abbr -a -- zshp 'vim ~/.zsh/.zsh_plugins.txt'
abbr -a -- ff 'find . -type f -name'
abbr -a -- fd 'find . -type d -name'
abbr -a -- explain 'unset github_token; gh copilot explain'
abbr -a -- ggroot 'cd $(git rev-parse --show-toplevel)'
abbr -a -- fb '_fzf_git_branches | xargs git checkout'
abbr -a -- freflog '_fzf_git_lreflogs | xargs git checkout'
abbr -a -- fishs 'vim ~/.config/fish/config.fish'

abbr -a -- ag rg
abbr -a -- s signadot

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx BREW_PREFIX /opt/homebrew
set -gx ZSH_CACHE_DIR (test -n "$XDG_CACHE_HOME" && echo "$XDG_CACHE_HOME" || echo "$HOME"'/.cache')'/zsh'
set -gx FZF_BASE "$BREW_PREFIX"'/opt/fzf'
set -gx FZF_DEFAULT_OPTS '--tmux 80% --layout=reverse --color=light --bind "tab:down,shift-tab:up,ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up" --bind="ctrl-/:change-preview-window(down,50%,border-top|hidden|)"'

fzf_configure_bindings \
    --directory=\cf \
    --git_status=\cgs \
    --git_log=\cgl \
    --history=\cr

function ggmain
    git checkout (__git.default_branch)
    git pull origin (__git.current_branch)
end
abbr -a -- ggm ggmain

function pass_to_aichat_widget
    # Retrieve the current command line input
    set current_input (commandline)
    # Replace the command line with 'aichat -e' followed by the current input
    commandline -r "aichat -e '$current_input'"
    # Execute the new command
    commandline -f execute
end
bind --mode insert \co pass_to_aichat_widget
abbr -a -- ?? 'aichat -e'

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
abbr -a -- gp gcloud-project

function gcloud-foreach-project
    if test (count $argv) -eq 0
        echo "Usage: gcloud-foreach-project <command>"
        return 1
    end

    set projects (gcloud projects list --format="value(projectId)" 2>/dev/null)

    if test -z "$projects"
        echo "No projects found"
        return 1
    end

    # Use parallel for concurrent execution - each project on a new line
    printf "%s\n" $projects | parallel -j 0 \
        "echo '=== Project: {} ==='; $argv --project={} 2>/dev/null; or true"
end
abbr -a -- gfp gcloud-foreach-project

function copilot-models
    curl -s https://api.githubcopilot.com/models \
        -H "Authorization: Bearer $COPILOT_KEY" \
        -H "Content-Type: application/json" \
        -H "Copilot-Integration-Id: vscode-chat" | jq -r '.data[].id'
end

function gcloud-account
    set account (gcloud auth list --format='table(account)' | grep -v ACCOUNT | fzf | string collect; or echo)
    gcloud config set account $account
end
abbr -a -- gac "gcloud-account; gcloud-project"

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
abbr -a -- guk gcloud-update-kubeconfig
abbr -a -- guki 'gcloud-update-kubeconfig --internal-ip'

function gcloud-fzf
    set cmd (__gcloud_sel | string collect; or echo)
    test -n "$cmd" && eval "$cmd"
end
abbr -a -- fgc gcloud-fzf

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
    echo ":pull-request: $msg :pray:" | tee /dev/tty | pbcopy
end

fish_vi_key_bindings
bind --mode insert --sets-mode default jj repaint
bind --mode insert \cw forward-word
bind --mode insert \cl accept-autosuggestion
bind --mode insert \cn accept-autosuggestion
bind --mode insert \cj complete
bind --mode insert \ck complete
