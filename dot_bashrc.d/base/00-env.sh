export VISUAL=vim
export EDITOR="$VISUAL"

# To let gpg key work on WSL
export GPG_TTY=$(tty)

export DOCKER_BUILDKIT=1

export PATH=$HOME/.cargo/bin:$PATH
