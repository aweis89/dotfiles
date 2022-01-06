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

# Colors
cache_cmd color-setup <<'EOL'
	pip install --user alacritty-colorscheme

	REPO="https://github.com/aaron-williamson/base16-alacritty.git"
	DEST="$HOME/.config/base16"
	
	# Get colorschemes 
	git clone $REPO $DEST
	# Create symlink at default colors location (optional)
	ln -s "$DEST/colors" "$HOME/.config/alacritty/colors"
EOL

LIGHT_COLOR='base16-gruvbox-light-soft.yml'
DARK_COLOR='base16-gruvbox-dark-soft.yml'

alias day="alacritty-colorscheme -V apply $LIGHT_COLOR"
alias night="alacritty-colorscheme -V apply $DARK_COLOR"
alias toggle="alacritty-colorscheme -V toggle $LIGHT_COLOR $DARK_COLOR"

cache_cmd link-dotflies <<EOL
	test -d $DOTFILES_PATH || \
		git clone https://github.com/aweis89/dotfiles.git $DOTFILES_PATH
	ln -s $DOTFILES_PATH/.tmux.conf ~/.tmux.conf || true
	ln -s $DOTFILES_PATH/nvim ~/.config/nvim || true
	ln -s $DOTFILES_PATH/.zsh ~/.zsh || true
	ln -s $DOTFILES_PATH/.zshrc ~/.zshrc || true
	ln -s $DOTFILES_PATH/alacritty.yml ~/.config/alacritty/alacritty.yml || true
EOL

antigen_dst=$HOME/.config/zsh/antigen.zsh
cache_cmd antigen <<EOL
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
cache_cmd brewsetup <<EOL
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	load_brew
	brew tap Homebrew/bundle
	# Insall all deps from Brewfile
	brew bundle --file $DOTFILES_PATH/Brewfile
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
