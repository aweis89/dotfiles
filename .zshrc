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
	local dir=$(dirname $cache_file)
	test -d $dir || mkdir -p $dir
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

antigen_dst=$HOME/.local/share/zsh/antigen.zsh
cache_cmd antigen <<'EOL'
	mkdir -p $(dirname $antigen_dst)
	curl -L git.io/antigen > $antigen_dst
EOL
source $antigen_dst

# Load the oh-my-zsh's library.
antigen use oh-my-zsh
antigen bundle ohmyzsh/ohmyzsh
# Bundles from the default repo (robbyrussell's oh-my-zsh).
antigen bundle ag
antigen bundle command-not-found
antigen bundle fzf
antigen bundle git
antigen bundle golang
antigen bundle kubectl
antigen bundle lein
antigen bundle npm
antigen bundle pip
antigen bundle tmux
antigen bundle yarn
antigen bundle z

# antigen bundle RobSis/zsh-completion-generator
antigen bundle zsh-users/zsh-syntax-highlighting
antigen bundle zsh-users/zsh-autosuggestions

# antigen theme simple
eval "$(starship init zsh)"

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
source_present $HOME/.zsh/kubectl.zsh

load_brew() {
	dist=$(uname -s)
	if [[ "${dist}" =~ "linux" ]]; then
		eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" 1>/dev/null
	fi
}

# brew
export PATH=$PATH:/opt/homebrew/bin:$HOME/.local/bin

# editor
export VISUAL=nvim
export EDITOR=$VISUAL

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
autoload -U +X compinit
compinit

# Fallback to using --help for autocompletion
compdef _gnu_generic \
	alacritty \
	alacritty-colorscheme \
	cargo
# Uncomment to enable for all commands
# compdef _gnu_generic $(ls $(echo $PATH | sed 's/:/ /g'))

colorscheme() {
	local colors_file=$1
	alacritty-colorscheme apply $colors_file
	local vim_colorscheme=$(echo $colors_file | sed -e 's/-256//' -e 's/\.yml//')
	echo "colorscheme $vim_colorscheme" >$HOME/.vimrc_background
}

_colorscheme() {
	cmds=($(ls -f $HOME/.config/alacritty/colors/))
	_describe 'profiles' cmds
}

alias c=colorscheme
autoload _colorscheme
compdef _colorscheme colorscheme

# alias bat='bat --theme $(cat $HOME/tmp/bat-theme)'

light() {
  kitty_set_theme ~/.local/share/nvim/lazy/tokyonight.nvim/extras/kitty/tokyonight_day.conf
}

dark() {
  kitty_set_theme ~/.local/share/nvim/lazy/tokyonight.nvim/extras/kitty/tokyonight_night.conf
}

kitty_set_theme() {
  theme_file=$1
  mkdir -p ~/.local/share/kitty
  ln -sf $theme_file ~/.local/share/kitty/current-theme.conf
	ps -ef | grep kitty | grep -v grep | awk '{print $2}' | xargs kill -s SIGUSR1
}

auto_start_tmux() {
	session=${1:-default}
	if test -z "$TMUX"; then
		tmux new-session -ds $session
		tmux attach -t $session
	fi
}

auto_start_tmux
export PATH="$HOME/.tfenv/bin:$PATH"
export PATH="/opt/homebrew/opt/openssl@3/bin:$PATH"

profile_cycle() {
	IFS=$'\n'
	sleep_time=${1:-0.5}
	for profile in $HOME/.config/alacritty/colors/*.yml; do
		echo Profile: $profile
		colorscheme $profile
		sleep $sleep_time
	done
}
