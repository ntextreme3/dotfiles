# cdr — revisit recent directories
#
# The picking lives in ~/.local/bin/cdr-pick so other tools (file-picker)
# can reuse it; only a function can change the current shell's directory.

cdr() {
  local dir
  dir=$(cdr-pick "$@") || return
  [[ -z "$dir" ]] && return
  builtin cd -- "$dir" || return
}
