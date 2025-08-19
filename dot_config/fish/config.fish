# Disable fish greeting message
set -g fish_greeting

# Add paths
fish_add_path \
    ~/.config/bin \
    ~/.local/bin \
    ~/.asdf/shims \
    ~/go/bin \
    /opt/homebrew/bin \
    /opt/homebrew/share/google-cloud-sdk/bin \
    /Applications/Docker.app/Contents/Resources/bin

if ! status is-interactive
    return
end

# Auto tmux
if test -z "$TMUX" && test -z "$NVIM"
    tmux new-session -ds default 2>/dev/null
    tmux attach -t default
end

alias cat="bat --theme auto:system --theme-dark default --theme-light GitHub"
alias d=z
alias tmux='TERM=screen-256color command tmux'
alias vim=nvim

set -g CDPATH . ~/p ~/c ~/q

# Commands to run in interactive sessions can go here
abbr -a -- ?? 'aichat -e'
abbr -a -- ag rg
abbr -a -- k kubectl
abbr -a -- ggpush 'git push origin (__git.current_branch)'
abbr -a -- ggpull 'git pull origin (__git.current_branch)'
abbr -a -- ai aichat
abbr -a -- dc docker-compose
abbr -a -- fd 'fd --hidden'
abbr -a -- fgc gcloud-fzf
abbr -a -- fishs 'nvim ~/.config/fish/config.fish'
abbr -a -- gac "gcloud-account; gcloud-project"
abbr -a -- gfp gcloud-foreach-project
abbr -a -- ggm ggmain
abbr -a -- ggr 'cd $(git rev-parse --show-toplevel)'
abbr -a -- gp gcloud-project
abbr -a -- guk gcloud-update-kubeconfig
abbr -a -- guki 'gcloud-update-kubeconfig --internal-ip'
abbr -a -- int 'curl -ss https://google.com'
abbr -a -- kb kubebuilder
abbr -a -- kcn kubens
abbr -a -- kcu kubectx
abbr -a -- kw 'watch kubectl'
abbr -a -- rms 'rm -rf ~/.local/share/nvim/swap/*'
abbr -a -- s signadot
abbr -a -- tf terraform
abbr -a -- tfa 'terraform apply -auto-approve'
abbr -a -- tfi 'terraform init'
abbr -a -- tmuxs 'nvim ~/.config/tmux/tmux.conf'
abbr -a -- tt gotestsum
abbr -a -- v nvim
abbr -a -- vims 'cd ~/.config/nvim/lua && vim'
abbr -a -- zshl 'nvim ~/.zshrc.local'
abbr -a -- zshp 'nvim ~/.zsh/.zsh_plugins.txt'
abbr -a -- zshs 'nvim ~/.zshrc'

set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx FZF_DEFAULT_OPTS '--tmux 80% --layout=reverse --color=light' \
    '--bind "tab:down,shift-tab:up,ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up"' \
    '--bind="ctrl-/:change-preview-window(down,50%,border-top|hidden|)"'

fzf_configure_bindings \
    --directory=\cf \
    --git_status=\cgs \
    --git_log=\cgl \
    --history=\cr

set sponge_purge_only_on_exit true

function watch_wrap
    set input (commandline)
    commandline -r "watch '$input'"
    commandline -f execute
end

fish_vi_key_bindings
bind --mode insert --sets-mode default jj repaint
bind --mode insert \co pass_to_aichat_widget
bind --mode insert \cw forward-word
bind --mode insert \cl accept-autosuggestion
bind --mode insert \cn accept-autosuggestion
bind --mode insert \cj complete
bind --mode insert \ck complete
bind --mode insert \cw watch_wrap

set --universal pure_enable_k8s true
set -g async_prompt_functions _pure_prompt_git

cache_tool_init zoxide "zoxide init fish" true
cache_tool_init direnv "direnv hook fish" true
