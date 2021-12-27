#!/bin/bash
set -eo pipefail

dotfiles=$HOME/dotfiles

mac_setup() {
	# install brew
	which brew 1>/dev/null || \
		/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	brew tap Homebrew/bundle
	brew bundle --file $dotfiles/Brewfile
}

global_setup() {
	ln -s $dotfiles/.tmux ~/.tmux
	ln -s $dotfiles/nvim ~/.config/nvim

	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -m|--mac)
			mac_setup
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

global_setup()
