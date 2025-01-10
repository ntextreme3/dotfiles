VISUAL=vim
EDITOR="$VISUAL"

# To let gpg key work on WSL
export GPG_TTY=$(tty)

export DOCKER_BUILDKIT=1

PATH=$HOME/.cargo/bin:$PATH
