# Start an ssh-agent just once per login, and reach it through a stable
# symlink so long-lived shells (e.g. tmux panes) keep working when the agent
# is restarted or a new forwarded agent arrives.

# Accept only a live socket that we own. The ownership check stops us handing
# keys to an agent another user planted where we'd look. ssh-add exits 2 only
# when it can't reach an agent at all.
_ssh_agent_ok() {
  [ -S "$1" ] && [ -O "$1" ] || return 1
  SSH_AUTH_SOCK="$1" ssh-add -l >/dev/null 2>&1
  [ $? -ne 2 ]
}

# Keep the link out of ~/.ssh, which some sandboxes hide, and in a directory
# only we can write, so nobody can swap it. The per-user runtime dir is private
# and cleared at boot. Otherwise fall back to ~/.cache, named per host in case
# $HOME is shared between machines.
if [ -d "${XDG_RUNTIME_DIR-}" ] && [ -O "$XDG_RUNTIME_DIR" ]; then
  _ssh_link="${XDG_RUNTIME_DIR%/}/ssh-agent.sock"
else
  mkdir -p "$HOME/.cache/ssh-agent" && chmod 700 "$HOME/.cache/ssh-agent"
  _ssh_link="$HOME/.cache/ssh-agent/$HOSTNAME.sock"
fi

# -ef compares the resolved sockets, so we never point the link at itself.
if _ssh_agent_ok "${SSH_AUTH_SOCK-}" && ! [ "$SSH_AUTH_SOCK" -ef "$_ssh_link" ]; then
  # Prefer an agent we inherited (forwarded over ssh, or started by the OS or a
  # login script).
  ln -sfn "$SSH_AUTH_SOCK" "$_ssh_link"
elif ! _ssh_agent_ok "$_ssh_link"; then
  # ssh-agent puts its socket in a fresh private directory under /tmp.
  eval "$(ssh-agent -s)" >/dev/null
  ln -sfn "$SSH_AUTH_SOCK" "$_ssh_link"
fi
export SSH_AUTH_SOCK="$_ssh_link"

unset -f _ssh_agent_ok
unset _ssh_link
