#!/bin/bash
set -euo pipefail

# install dependencies
sudo apt update
sudo apt install -y --no-upgrade build-essential cmake bash-completion

# install tools with apt
sudo apt install -y --no-upgrade curl git tmux ripgrep jq rustup tree kubectx net-tools

# install tools with snap
sudo snap install jqp
sudo snap install yq
sudo snap install go --classic
sudo snap install kubectl --classic

# setup rust
rustup default stable

# rustup upgrade ?

# install tools with cargo
cargo install --locked git-delta starship

# install tools with go
go install github.com/junegunn/fzf@latest
