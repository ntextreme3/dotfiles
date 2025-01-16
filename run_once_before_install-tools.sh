#!/bin/bash
set -euo pipefail

# install dependencies
sudo apt update
sudo apt install -y --no-upgrade build-essential cmake

# install pyenv recommended deps
sudo apt install -y --no-upgrade build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl git \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev

# install things with apt
sudo apt install -y --no-upgrade tmux ripgrep jq rustup tree

# install things with snap
sudo snap install jqp
sudo snap install yq

# setup rust
rustup default stable

# install crates
cargo install --locked git-delta starship
