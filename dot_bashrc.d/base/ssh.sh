# Start an ssh-agent just once per login
if [ ! -S ~/.ssh/ssh_auth_sock ]; then
  eval $(ssh-agent -s)
  ln -sf "$SSH_AUTH_SOCK" ~/.ssh/ssh_auth_sock
fi
export SSH_AUTH_SOCK=~/.ssh/ssh_auth_sock
