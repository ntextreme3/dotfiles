#!/bin/bash
set -euo pipefail

# This would normally be set inside a tmux session.
export TMUX_PLUGIN_MANAGER_PATH=/home/ntrenchi/.tmux/plugins/

# Install tmux plugins via tpm (alternative is prefix+I in tmux)
~/.tmux/plugins/tpm/bin/install_plugins
