export VISUAL=vim
export EDITOR="$VISUAL"

# To let gpg key work on WSL
export GPG_TTY=$(tty)

# Includes starship and other crates
PATH=$HOME/.cargo/bin:$PATH

# Include Go binaries
PATH=$(go env GOPATH)/bin:$PATH
