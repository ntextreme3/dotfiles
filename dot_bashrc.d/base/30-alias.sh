# I had the exact same issue as, and attempted the same alternatives, as:
# https://github.com/twpayne/chezmoi/issues/3719. Basically, I want a way to
# *privately* split my work "profile" out, without even making a reference to
# work-specific things (e.g. filenames, urls) in my public branch.
#
# This hack allows splitting chezmoi across home and work repos. It works best
# when you can spread the settings for each dotfile across different files (e.g.
# ~/.bashrc.d/*), and "include" them; OR, use templated files (see my .gitconfig
# example, which does both).
#
# WARNING: You can't track the same file in both, but, if truly needed, you can
# use a `modify_` script to edit part of a file:
# https://www.chezmoi.io/user-guide/manage-different-types-of-file/#manage-part-but-not-all-of-a-file
alias chezwork="chezmoi -S ~/.local/share/chezmoi_work -c ~/.config/chezmoi_work/chezmoi.toml"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# some more ls aliases
alias ll='ls -lF'
alias la='ls -A'

# gits = "git side-by-side"
alias gits="git -c delta.side-by-side=true"

# can't setup multiple completions per command
# _fzf_setup_completion path gits

# NOTE: Not sure how portable this is yet ...
_completion_loader git
complete -o bashdefault -o default -o nospace -F __git_wrap__git_main gits
