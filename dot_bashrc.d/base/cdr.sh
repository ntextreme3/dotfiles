# cdr — revisit recent directories
#
# Two-stage fzf:
#   1. Pick a recent cd target from history (ctrl-d to skip stage 2)
#   2. Locate it on the filesystem
cdr() {
  local out key query dir

  # fc -lnr: no line numbers, reverse (most recent first)
  out=$(
    fc -lnr -5000 2>/dev/null |
    command sed -n 's/^[[:space:]]*cd  *//p' |
    command grep -vxE '[._-]+([/._-]*)*|^$' |
    command sed "s|^~/|$HOME/|" |
    command awk '!seen[$0]++' |
    command head -100 |
    command fzf --reverse --expect=ctrl-d \
        --header='enter=search for <dir> with fzf | ctrl-d=cd <dir>'
  ) || return

  key=$(command head -1 <<< "$out")
  query=$(command tail -1 <<< "$out")
  [[ -z "$query" ]] && return

  if [[ "$key" == "ctrl-d" ]]; then
    builtin cd -- "${query/#\~/$HOME}" || return
  else
    dir=$(
      command fzf --walker=dir,follow \
          --walker-root="${CDR_SEARCH_ROOT:-$HOME}" \
          --scheme=path --reverse +m \
          --query "'${query%/}/'" \
          --header='Select directory'
    ) || return
    builtin cd -- "$dir" || return
  fi
}
