# Kubernetes
# 1. install bash completion (Ubuntu installs by default, but we also manually do it via install script)
# 2. `source /etc/bash_completion` (Ubuntu does by default in `/etc/bash.bashrc`)
# 3. setup kubectl completion (see post-install script)
# 4. connection completion to alias:
alias k=kubectl
complete -o default -F __start_kubectl k
