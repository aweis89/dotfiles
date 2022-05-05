#!/bin/bash
set -eo pipefail

DOTFILES_PATH=$HOME/dotfiles
GO_DEPS=(
	github.com/haveyoudebuggedit/gotestfmt/v2/cmd/gotestfmt@latest
	github.com/cweill/gotests/gotests@latest
)

brew_deps() {
	# install brew, requires ruby to be installed
	which brew 1>/dev/null || \
		ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	dist=$(uname -s)
	if [[ "${dist,,}" =~ "linux" ]]
	then
		test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
		test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
		test -r ~/.zshrc && echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.zshrc
		echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >>~/.profile
	fi

	brew tap Homebrew/bundle
	brew bundle --file $DOTFILES_PATH/Brewfile
}

install_kubectl() {
    tmp_dir=$(mktemp -d -t tmp-XXXXXXXXXX)
    cd $tmp_dir
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
    echo "$(<kubectl.sha256)  kubectl" | sha256sum --check
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -rf $tmp_dir

    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
}

link_configs() {
	test -d $HOME/.config || mkdir $HOME/.config
	test -d $HOME/.config/alacritty || mkdir $HOME/.config/alacritty
	test -d $HOME/.zsh || mkdir $HOME/.zsh
	test -d $DOTFILES_PATH || \
		git clone https://github.com/aweis89/dotfiles.git $DOTFILES_PATH
	ln -s $DOTFILES_PATH/.tmux.conf ~/.tmux.conf || true
	ln -s $DOTFILES_PATH/nvim ~/.config/nvim || true
	ln -s $DOTFILES_PATH/.zsh ~/.zsh || true
	ln -s $DOTFILES_PATH/.zshrc ~/.zshrc || true
	ln -s $DOTFILES_PATH/alacritty.yml ~/.config/alacritty/alacritty.yml || true
}

go_deps() {
	for dep in $GO_DEPS
	do
		go install $dep
	done
}

neovim_setup() {
	# install neovim with lua and lsp support
	local should_install=$1
	if $should_install
	then
		brew tap jason0x43/neovim-nightly
		brew install neovim
	fi

	# plugin manager should self install and then install all deps
	nvim --headless -c 'autocmd User PackerComplete quitall' \
		-c 'PackerSync'

	nvim --headless -c 'GoInstallBinaries'
}

while [[ "$#" -gt 0 ]]; do
	# defaults
	ALSO_INSTALL=false

    case "$1" in
		-i|--install)
			ALSO_INSTALL=true
            shift
            ;;
        -b|--brew)
			brew_deps
            shift
            ;;
		-nv|--nvim)
			neovim_setup
            shift
            ;;
		-l|--link)
			link_configs
            shift
            ;;
		-a|--all)
			brew_deps
			link_configs
			go_deps
			neovim_setup $ALSO_INSTALL
            shift
            ;;
    	--)
            shift
            break
            ;;
        *)
            echo "Arg not known"
            exit 3
            ;;
    esac
done
