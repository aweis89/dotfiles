# Agent Guidelines for Chezmoi Dotfiles

## Overview
This is a chezmoi-managed dotfiles repository with configs for Fish shell, Neovim (LazyVim), Hammerspoon, tmux, and macOS settings.

## Build/Test/Lint Commands
- **Apply changes**: `chezmoi apply` (run after editing source files)
- **Check diff**: `chezmoi diff` (preview what would change)
- **Edit file**: `chezmoi edit <target-path>` (edits source, not target)
- **Test shell config**: `fish -n <fish-file>` (syntax check)
- **Test Lua (Neovim/Hammerspoon)**: `lua -l <lua-file>` or check in respective app
- **Go linting**: `golangci-lint run` (config: dot_golangci.yml)
- **Install packages**: `brew bundle` (from Brewfile)

## Code Style & Conventions
- **Shell scripts**: Use POSIX sh for hooks/templates; fish for interactive configs
- **Fish**: Use functions over aliases where possible; follow existing abbr conventions (k=kubectl, gc=git commit, etc.)
- **Lua**: LazyVim conventions for Neovim; Hammerspoon spoon patterns
- **Naming**: Chezmoi prefixes: `dot_` for dotfiles, `run_once_` for setup scripts, `private_` for sensitive data
- **Go**: Use golangci.yml config (gofmt, gofumpt, goimports enabled; funlen, varnamelen disabled)
- **Error handling**: Shell scripts use `set -eo pipefail`; check exit codes explicitly where needed

## Important Patterns
- Edit files in chezmoi source (`~/.local/share/chezmoi`), not home directory targets
- Git hooks auto-run `chezmoi apply` after merge/rebase
- Run-once scripts skip with env vars (e.g., SKIP_BREW)
- Fish config uses vi keybindings with jj escape; tmux auto-attaches
