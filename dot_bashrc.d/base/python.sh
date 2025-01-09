PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init - bash)"
eval "$(pyenv virtualenv-init - bash)"

# virtualenv defaults
export VIRTUALENV_SYMLINK_APP_DATA=1
export VIRTUALENV_ACTIVATORS="bash"
export VIRTUALENV_PROMPT="."
export PIP_REQUIRE_VIRTUALENV=true

# Python
# https://docs.python.org/3/library/devmode.html#effects-of-the-python-development-mode
# export PYTHONDEVMODE=1
# export PYTHONWARNINGS=error
# export PYTHONASYNCIODEBUG=1
