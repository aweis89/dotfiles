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

tmux_setup() {
	ln -sf $dotfiles/.tmux ~/.tmux
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

nvim_setup() {
	brew install neovim
	ln -s $dotfiles/nvim ~/.config/nvim
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -m|--mac)
			mac_setup
            shift
            ;;
        -lsp|--language-servers)
			language_servers
            shift
            ;;
        -t|--tmux)
			tmux_setup
            shift
            ;;
        -n|--nvim)
			nvim_setup
            shift
            ;;
        -a|--all)
			mac_setup
			tmux_setup
			nvim_setup
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
