# TODO: Should this go with "history"?
# Save each command after executed
PROMPT_COMMAND='history -a'

#--------
# # Going to give starship a try ...

# # Set git shell modifiers
# export GIT_PS1_SHOWDIRTYSTATE=1           # '*'=unstaged, '+'=staged
# export GIT_PS1_SHOWSTASHSTATE=1           # '$'=stashed
# export GIT_PS1_SHOWUPSTREAM="verbose"     # 'u='=no difference, 'u+1'=ahead by 1 commit

# # Set PS1 w/ Colors
# __XTERM_TITLE='\[\e]0;\u@\h:\w\a\]'
# __PS_USER='\[\e[31m\]\u\[\e[m\]'  # Color User Red
# __PS_HOST='\[\e[32m\]\h\[\e[m\]'  # Color Host Green
# PS1="$__XTERM_TITLE"'['"$__PS_USER@$__PS_HOST"' \W$(__git_ps1 " (%s)")]\$ '

# https://starship.rs/
eval "$(starship init bash)"
