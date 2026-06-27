#!/bin/sh
# Shared helper: run chezmoi apply and report status.
# Sourced by post-merge and post-rewrite hooks.

echo "Running chezmoi apply to update configuration files..."
if chezmoi apply; then
    echo "✓ Configuration files updated successfully"
else
    echo "✗ Error updating configuration files"
    exit 1
fi
