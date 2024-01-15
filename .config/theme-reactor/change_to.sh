#!/bin/bash

# Function to handle the 'light' event
handle_light_event() {
    echo "Handling light event..."
    # Add the commands for the light event here
    # Example: Change tmux, nvim, and kitty themes for light mode
    tmux source-file ~/.config/tmux/tmux.conf
    touch ~/.config/nvim/lua/plugins/editor.lua
    kitty +kitten themes --reload-in=all "Catppuccin Kitty Latte"
}

# Function to handle the 'dark' event
handle_dark_event() {
    echo "Handling dark event..."
    # Add the commands for the dark event here
    # Example: Change tmux, nvim, and kitty themes for dark mode
    tmux source-file ~/.config/tmux/tmux.conf
    touch ~/.config/nvim/lua/plugins/editor.lua
    kitty +kitten themes --reload-in=all "Catppuccin Kitty Mocha"
}

# Main logic to determine which event to handle
if [ "$1" == "light" ]; then
    handle_light_event
elif [ "$1" == "dark" ]; then
    handle_dark_event
else
    echo "Invalid argument. Please specify 'light' or 'dark'."
fi
