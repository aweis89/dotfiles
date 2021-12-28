#!/bin/bash
set -eo pipefail

dotfiles=$HOME/dotfiles

brew_deps() {
	# install brew
	which brew 1>/dev/null || \
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	brew tap Homebrew/bundle
	brew bundle --file $dotfiles/Brewfile
}

global_setup() {
	test -d $dotfiles || \
		git clone https://github.com/aweis89/dotfiles.git $dotfiles

	ln -s $dotfiles/.tmux.conf ~/.tmux.conf || true
	ln -s $dotfiles/nvim ~/.config/nvim || true
	ln -s $dotfiles/.zsh ~/.zsh || true
	ln -s $dotfiles/.zshrc ~/.zshrc || true

	test -d ~/.tmux/plugins/tpm || \
		git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

	go install github.com/haveyoudebuggedit/gotestfmt/v2/cmd/gotestfmt@latest
	go install github.com/cweill/gotests/gotests@latest

	nvim --headless -c 'autocmd User PackerComplete quitall' \
		-c 'GoInstallBinaries' \
		-c 'PackerSync'
}

#while [[ "$#" -gt 0 ]]; do
#    case "$1" in
#        -b|--brew)
#			brew_deps
#            shift
#            ;;
#        --)
#            shift
#            break
#            ;;
#        *)
#            echo "Arg not known"
#            exit 3
#            ;;
#    esac
#done

brew_deps
global_setup
