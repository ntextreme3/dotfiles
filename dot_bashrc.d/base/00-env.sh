export VISUAL=vim
export EDITOR="$VISUAL"

# To let gpg key work on WSL
export GPG_TTY=$(tty)

# Includes starship and other crates
PATH=$HOME/.cargo/bin:$PATH

# Go binaries; 05-mise.sh activates after this file, so `go env GOPATH` isn't available yet
PATH=$HOME/go/bin:$PATH

# pending: https://github.com/anthropics/claude-code/issues/85776
export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1
