# bullshit for node.js and nvm to speed up opening new terminals
NVM_DIR="$HOME/.nvm"
function _install_nvm() {
  unset -f nvm npm node npx
  # This loads "nvm". We could use "--no-use" to defer setup and make it a bit
  # faster, but I don't use node enough for it to matter.
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  "$@"
}

function nvm() {
    _install_nvm nvm "$@"
}

function npm() {
    _install_nvm npm "$@"
}

function node() {
    _install_nvm node "$@"
}

function npx() {
    _install_nvm npx "$@"
}
