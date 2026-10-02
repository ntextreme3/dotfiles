# cdr — revisit recent directories
#
# Paths are normalized to relative-to-$HOME before dedup.
#
# Two-stage fzf:
#   1. Pick a recent cd target from history (ctrl-d to skip stage 2)
#   2. Locate it on the filesystem
cdr() {
  local out key query dir initial_query="$1"

  # Scan the whole history file, including other sessions. tac: most recent first.
  out=$(
    command tac "${HISTFILE:-$HOME/.bash_history}" 2>/dev/null |
    command sed -n 's/^[[:space:]]*cd  *//p' |
    # drop chained commands: `cd x && make` → x
    command sed -E 's/[[:space:]]*(&&|\|\||[;|]).*//; s/[[:space:]]+$//' |
    # command substitutions like `cd $(git root)` aren't reusable paths
    command grep -vF '$(' |
    command grep -vxE '[._-]+([/._-]*)*|^$' |
    command awk -v home="$HOME" '{
      # ~/x and $HOME/x → x (dedup relative vs absolute forms)
      sub("^~/", home "/")
      sub("^" home "/", "")
      # strip leading ../ segments (CWD context is lost)
      while (sub("^\\.\\./", "")) {}
      gsub(/\/+$/, "")
      if ($0 != "" && !seen[$0]++) print
    }' |
    command head -1000 |
    command fzf --reverse --expect=ctrl-d \
        ${initial_query:+--query "$initial_query"} \
        --header='enter=search for <dir> with fzf | ctrl-d=cd <dir>'
  ) || return

  key=$(command head -1 <<< "$out")
  query=$(command tail -1 <<< "$out")
  [[ -z "$query" ]] && return

  if [[ "$key" == "ctrl-d" ]]; then
    if [[ "$query" == /* ]]; then
      builtin cd -- "$query" || return
    else
      # paths are relative-to-$HOME after normalization; fall back to CWD
      builtin cd -- "$HOME/$query" 2>/dev/null || builtin cd -- "$query" || return
    fi
  else
    dir=$(
      command fzf --walker=dir,follow \
          --walker-root="${CDR_SEARCH_ROOT:-$HOME}" \
          --scheme=path --reverse +m \
          --query "'${query##*/}/'" \
          --header='Select directory'
    ) || return
    builtin cd -- "$dir" || return
  fi
}
