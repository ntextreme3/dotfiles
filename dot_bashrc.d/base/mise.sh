# mise manages node (and any other runtimes); see ~/.config/mise/config.toml.
# Use the absolute path: ~/.profile sources ~/.bashrc before it puts
# ~/.local/bin on PATH, so login shells can't find mise by name yet.
if [ -x "$HOME/.local/bin/mise" ]; then
  eval "$("$HOME/.local/bin/mise" activate bash)"
fi
