#!/bin/bash
set -euo pipefail

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "tmux is not installed, skipping plugin installation"
    exit 0
fi

# This would normally be set inside a tmux session.
export TMUX_PLUGIN_MANAGER_PATH=/home/ntrenchi/.tmux/plugins/

# Install tmux plugins via tpm (alternative is prefix+I in tmux)
~/.tmux/plugins/tpm/bin/install_plugins
