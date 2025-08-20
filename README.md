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

## Actively used

There are multiple options for some tools, the following is a list of the currently used tools that will be kept up-to-date
- Using ghostty as my current terminal, perviously kitty
- Using fish as my shell, previoulsy zsh
- Using neovim with lazyvim
