#!/bin/bash

# Script to install all fonts in the current directory
# Works on macOS

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FONT_DIR="$HOME/Library/Fonts"

echo "Installing fonts from: $SCRIPT_DIR"
echo "Target directory: $FONT_DIR"
echo ""

# Counter for installed fonts
count=0

# Find and copy all font files
shopt -s nullglob
for font in "$SCRIPT_DIR"/*.otf "$SCRIPT_DIR"/*.ttf "$SCRIPT_DIR"/*.OTF "$SCRIPT_DIR"/*.TTF; do
    if [ -f "$font" ]; then
        filename=$(basename "$font")
        echo "Installing: $filename"
        cp "$font" "$FONT_DIR/"
        ((count++))
    fi
done
shopt -u nullglob

if [ $count -eq 0 ]; then
    echo "No font files found in the current directory."
    exit 1
else
    echo ""
    echo "Successfully installed $count font(s)!"
    echo "You may need to restart applications to see the new fonts."
fi
