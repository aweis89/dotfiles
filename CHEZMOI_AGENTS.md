# Agent Guidelines for Chezmoi Dotfiles

Chezmoi-managed dotfiles for Fish shell, Neovim (LazyVim), Hammerspoon, tmux, and macOS.

## Commands
- `chezmoi apply <target>` - apply changes for a specific file (e.g., `chezmoi apply ~/.config/fish/config.fish`)
- `chezmoi diff` - preview changes before applying
- `fish -n <file>` - syntax check Fish scripts
- `golangci-lint run` - lint Go code (uses dot_golangci.yml)
- `brew bundle` - install packages from Brewfile

## Code Style
- **Shell**: POSIX sh for hooks/templates (`set -eo pipefail`); Fish for interactive configs
- **Fish**: Prefer functions over aliases; use abbr conventions (k=kubectl, gc=git commit)
- **Lua**: LazyVim conventions for Neovim; Hammerspoon spoon patterns
- **Go**: gofmt/gofumpt/goimports enabled; funlen/varnamelen disabled
- **Chezmoi naming**: `dot_` for dotfiles, `run_once_` for setup scripts, `private_` for sensitive

## Key Patterns
- After editing a file, run `chezmoi apply <target>` to apply your changes (e.g., after editing `dot_config/fish/config.fish`, run `chezmoi apply ~/.config/fish/config.fish`)
- Always edit in chezmoi source (`~/.local/share/chezmoi`), not home directory targets
- Git hooks auto-run `chezmoi apply` after merge/rebase
- Skip run-once scripts with env vars (e.g., `SKIP_BREW=1`)
- Fish uses vi keybindings with `jj` to exit insert mode
