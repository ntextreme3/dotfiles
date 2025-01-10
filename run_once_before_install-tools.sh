#!/bin/bash
set -euo pipefail

# install dependencies
sudo apt update
sudo apt install -y build-essential cmake

# install things with apt
missing_apts=$(python3 _find_missing_packages.py tmux rg::ripgrep jq rustup tree)
if [[ ! -z $missing_apts ]]; then
    sudo apt install -y $missing_apts
fi

# install things with snap
missing_snaps=$(python3 _find_missing_packages.py jqp yq)
if [[ ! -z $missing_snaps ]]; then
    sudo snap install $missing_snaps
fi

# setup rust
rustup default stable

# install crates
cargo install --locked git-delta starship
