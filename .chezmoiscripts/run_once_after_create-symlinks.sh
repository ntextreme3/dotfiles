#!/bin/bash
set -euo pipefail

# `bat` via apt is installed as `batcat` due to a name conflict
sudo ln -sf "$(command -v batcat)" ~/.local/bin/bat
