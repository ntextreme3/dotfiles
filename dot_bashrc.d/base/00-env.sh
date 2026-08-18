export VISUAL=vim
export EDITOR="$VISUAL"

# To let gpg key work on WSL
export GPG_TTY=$(tty)

# Includes starship and other crates
PATH=$HOME/.cargo/bin:$PATH

# Include Go binaries if `go` is installed
if command -v go &> /dev/null; then
    PATH=$(go env GOPATH)/bin:$PATH
fi

# pending: https://github.com/anthropics/claude-code/issues/85776
export CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1
