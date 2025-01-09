# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Ignore certain commands
HISTIGNORE="ls:bg:fg:history:pwd:tmux:rm:cd ..:jobs"

# Show timestamps in history %F=YYYY-MM-DD and %T=HH:MM:SS
HISTTIMEFORMAT='%F %T '

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1
