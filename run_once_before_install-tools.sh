#!/bin/bash
set -euo pipefail

# install dependencies
sudo apt update
sudo apt install -y build-essential cmake

# install pyenv recommended deps
sudo apt install -y --no-upgrade build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl git \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# install things with apt
missing_apts=$(python3 ${CHEZMOI_SOURCE_DIR}/_find_missing_packages.py tmux rg::ripgrep jq rustup tree)
if [[ ! -z $missing_apts ]]; then
    sudo apt install -y $missing_apts
fi

# install things with snap
missing_snaps=$(python3 ${CHEZMOI_SOURCE_DIR}/_find_missing_packages.py jqp yq)
if [[ ! -z $missing_snaps ]]; then
    sudo snap install $missing_snaps
fi

# setup rust
rustup default stable

# install crates
cargo install --locked git-delta starship
