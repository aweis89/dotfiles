#!/bin/bash

# Function to handle the 'light' event
handle_light_event() {
    echo "Handling light event..."
    # Add the commands for the light event here
    # Example: Change tmux and nvim themes for light mode
    tmux source-file ~/.config/tmux/tmux.conf
    touch ~/.config/nvim/lua/plugins/editor.lua
}

# Function to handle the 'dark' event
handle_dark_event() {
    echo "Handling dark event..."
    # Add the commands for the dark event here
    # Example: Change tmux and nvim themes for dark mode
    tmux source-file ~/.config/tmux/tmux.conf
    touch ~/.config/nvim/lua/plugins/editor.lua
}

# Main logic to determine which event to handle
if [ "$1" == "light" ]; then
    handle_light_event
elif [ "$1" == "dark" ]; then
    handle_dark_event
else
    echo "Invalid argument. Please specify 'light' or 'dark'."
fi
