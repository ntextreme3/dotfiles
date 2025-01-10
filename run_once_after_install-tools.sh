#!/bin/bash
set -euo pipefail

# install things with snap
missing_snaps=$(python3 _find_missing_packages.py jqp yq)
if [[ ! -z $missing_snaps ]]; then
    sudo snap install $missing_snaps
fi

# install things with apt
sudo apt update
missing_apts=$(python3 _find_missing_packages.py tmux rg::ripgrep jq rustup tree)
if [[ ! -z $missing_apts ]]; then
    sudo apt install -y $missing_apts
fi

# setup rust
rustup default stable

# install crates
cargo install --locked git-delta starship
