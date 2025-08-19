# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io).

## Installation

### Quick Setup (New Machine)

```bash
# Install chezmoi (if not already installed)
brew install chezmoi

# Initialize and apply dotfiles in one command
chezmoi init --apply https://github.com/username/dotfiles.git
```

### Manual Setup

```bash
# Install chezmoi
brew install chezmoi

# Initialize with this repo
chezmoi init https://github.com/username/dotfiles.git

# Review changes before applying
chezmoi diff

# Apply the configuration
chezmoi apply

# The setup scripts will run automatically to:
# - Install Homebrew packages from Brewfile
# - Configure macOS settings
# - Set up startup applications
```

## Usage

### Daily Operations

```bash
# Edit a dotfile (opens source file in editor)
chezmoi edit ~/.zshrc

# Apply changes after editing
chezmoi apply

# Update from remote repository
chezmoi update

# Check what would change
chezmoi diff
```

### Adding New Files

```bash
# Add a new dotfile to chezmoi management
chezmoi add ~/.someconfig

# Add and edit in one command  
chezmoi add --autotemplate ~/.someconfig
```

## Structure

- **Homebrew packages**: `Brewfile` - managed by chezmoi run-once scripts
- **Shell config**: `.zshrc`, `.p10k.zsh`, `.zsh/` directory
- **Application configs**: `.config/` directory with various app configurations
- **Scripts**: `.config/bin/` - custom utility scripts
- **Setup automation**: `run_once_*.sh` - automated setup scripts that run on first apply

## Migration from Stow

This repo was previously managed with GNU Stow. The migration to chezmoi provides:

- Better cross-platform support
- Templating capabilities for machine-specific configs
- Automatic script execution (run-once, run-always)
- More robust file state management
- Built-in git integration

The old `setup` script functionality has been replaced with chezmoi's run-once scripts that handle:
- Package installation via Homebrew
- macOS configuration
- Application setup
