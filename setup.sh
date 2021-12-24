#!/bin/bash
set -eo pipefail

dotfiles=$HOME/dotfiles

mac_setup() {
	# fonts
	brew tap homebrew/cask-fonts
	brew install --cask font-hack-nerd-font
	brew install reattach-to-user-namespace
}

tmux_setup() {
	brew install tmux
	ln -sf $dotfiles/.tmux ~/.tmux
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

nvim_setup() {
	brew install neovim

	packer_dest=~/.local/share/nvim/site/pack/packer/start/packer.nvim
	test -d $packer_dest || \
		git clone --depth 1 https://github.com/wbthomason/packer.nvim $packer_dest
	nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

language_servers() {
	npm i -g bash-language-server
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
        -v|--nvim)
			nvim_setup
            shift
            ;;
        -a|--all)
			mac_setup
			tmux_setup
			nvim_setup
			language_servers
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
