export PATH=$PWD/venv/bin:$PATH

_cache_key_file() {
	local cache_dir=${CACHE_DIR:-$HOME/tmp}
	local key=${1}.cache
	echo $cache_dir/$key
}

cache_rm() {
	local cache_file=$(_cache_key_file $key)
	rm $cache_file
}

cache_cmd() {
	local key=$1
	local cache_file=$(_cache_key_file $key)
	[[ ! -f $cache_file ]] || return 0

	local cmds="$(cat /dev/stdin)"
	set -x
	eval "$cmds"
	touch $cache_file
	set +x
}

cache_cmd link-dotflies <<'EOL'
	DOTFILES_PATH=$HOME/dotfiles
	test -d $DOTFILES_PATH || \
		git clone https://github.com/aweis89/dotfiles.git $DOTFILES_PATH
	ln -sf $DOTFILES_PATH/.zshrc ${ZDOTDIR:-$HOME}/.zshrc
	ln -sf $DOTFILES_PATH/.tmux.conf ~/.tmux.conf
	ln -sf $DOTFILES_PATH/nvim ~/.config/nvim
	ln -sf $DOTFILES_PATH/alacritty.yml ~/.config/alacritty/alacritty.yml
EOL

antigen_dst=$HOME/.config/zsh/antigen.zsh
cache_cmd antigen <<'EOL'
	mkdir -p $(dirname $antigen_dst)
	curl -L git.io/antigen > $antigen_dst
EOL
source $antigen_dst

# Load the oh-my-zsh's library.
antigen use oh-my-zsh
# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle git
antigen bundle golang
antigen bundle lein
antigen bundle npm
antigen bundle pip
# antigen bundle rust
antigen bundle tmux
antigen bundle yarn
antigen bundle fzf
antigen bundle z

# antigen bundle RobSis/zsh-completion-generator
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle mafredri/zsh-async
antigen bundle ahmetb/kubectx path:completion kind:fpath

antigen theme simple

# Tell Antigen that you're done.
antigen apply

source_present() {
	local -r file="$1"
	test -r $file && . $file
}

source_present $HOME/.zshrc.local
source_present $HOME/.zsh/completion.zsh
source_present $HOME/.zsh/history.zsh
source_present $HOME/.zsh/alias.zsh

load_brew() {
	dist=$(uname -s)
	if [[ "${dist}" =~ "linux" ]]
	then
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 1>/dev/null
	fi
}

load_brew

# Brew package manager setup, assumes ruby is installed
cache_cmd brewsetup <<'EOL'
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	load_brew
	brew tap Homebrew/bundle
	# Insall all deps from Brewfile
	brew bundle --file $DOTFILES_PATH/Brewfile
EOL

# Colors
cache_cmd color-setup <<'EOL'
	pip install --user alacritty-colorscheme

	REPO="https://github.com/aaron-williamson/base16-alacritty.git"
	DEST="$HOME/.config/base16"
	
	# Get colorschemes 
	git clone $REPO $DEST
	# Create symlink at default colors location (optional)
	mkdir -p $HOME/.config/alacritty
	ln -sf $DEST/colors $HOME/.config/alacritty
EOL

# Completion init
autoload -U +X compinit; compinit

# Fallback to using --help for autocompletion
compdef _gnu_generic \
	alacritty \
	alacritty-colorscheme \
	cargo
# Uncomment to enable for all commands
# compdef _gnu_generic $(ls $(echo $PATH | sed 's/:/ /g'))

colorscheme() {
    local colors_file=$1
	alacritty-colorscheme -c /mnt/c/Users/$USER/AppData/Roaming/alacritty/alacritty.yml apply $colors_file
    local vim_colorscheme=$(echo $colors_file | sed -e 's/-256//' -e 's/\.yml//')
    echo "colorscheme $vim_colorscheme" > $HOME/.vimrc_background
}

_colorscheme() {
    cmds=($(ls -f $HOME/.config/alacritty/colors/)) 
    _describe 'profiles' cmds
}

alias c=colorscheme
autoload _colorscheme
compdef _colorscheme colorscheme

LIGHT_COLOR='base16-gruvbox-light-soft.yml'
DARK_COLOR='base16-gruvbox-dark-soft.yml'

alias day="colorscheme $LIGHT_COLOR"
alias night="colorscheme $DARK_COLOR"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
