# Tests for dot_local/bin/executable_file-picker
#
# tmux, herdr, fd, fzf, pgrep and cdr-pick are replaced by stubs on PATH (see
# test_helper.bash). The stubs log what the picker asked of them so tests can
# check what reached the pane.
#
# fzf runs with --print-query --expect, so each stubbed fzf output is: query
# line, key line (empty for enter), then the picked paths.
#
# Run: prek run bats --all-files

load test_helper

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../dot_local/bin/executable_file-picker"
  setup_stubs
  export HOME="$BATS_TEST_TMPDIR"
  export SENT="$BATS_TEST_TMPDIR/sent" FD_CWDS="$BATS_TEST_TMPDIR/fd-cwds"
  export FD_ARGS="$BATS_TEST_TMPDIR/fd-args"
  REPO="$BATS_TEST_TMPDIR/repo"
  export PANE_DIR="$REPO/project"
  ELSEWHERE="$BATS_TEST_TMPDIR/elsewhere"
  mkdir -p "$PANE_DIR/sub" "$ELSEWHERE"
  git -C "$REPO" init -q

  # Records each directory fd searched and its args, one line per call; the
  # file list itself comes from fzf.
  stub fd 'pwd >>"$FD_CWDS"; echo "$*" >>"$FD_ARGS"'
  # Only claude panes have a matching child process.
  stub pgrep '[ "${PANE_AGENT-}" = claude ]'
  stub tmux '
    case "$1" in
      display-message) case "$3" in
          "#{pane_id}") echo "%7" ;;
          "#{pane_pid}") echo 1234 ;;
          "#{pane_current_path}") echo "$PANE_DIR" ;;
        esac ;;
      send-keys) shift; printf "%s\n" "$@" >"$SENT" ;;
    esac'
  stub herdr '
    case "$1 $2" in
      "pane get") printf "{\"result\":{\"pane\":{\"agent\":%s,\"foreground_cwd\":\"%s\",\"pane_id\":\"%s\"}}}\n" \
          "$( [ -n "${PANE_AGENT-}" ] && echo "\"$PANE_AGENT\"" || echo null)" "$PANE_DIR" "$3" ;;
      "pane send-text") shift 2; printf "%s\n" "$@" >"$SENT" ;;
    esac'
}

# Run the picker as a tmux popup would: inside tmux, from some other dir.
pick_in_tmux() {
  cd "$BATS_TEST_TMPDIR"
  run env TMUX=/tmp/tmux-sock,1,0 "$@" bash "$SCRIPT" </dev/null
}

# Run the picker as a herdr popup would: no HERDR_PANE_ID, only the active pane.
pick_in_herdr() {
  cd "$BATS_TEST_TMPDIR"
  run env -u TMUX HERDR_ACTIVE_PANE_ID=w1:p2 "$@" bash "$SCRIPT" </dev/null
}

# Assert the Nth directory fd searched.
assert_searched() {
  local actual
  actual=$(sed -n "${1}p" "$FD_CWDS")
  if [ "$actual" != "$2" ]; then
    printf 'search %s: expected %s, got %s\n' "$1" "$2" "$actual"
    return 1
  fi
}

# Print the --type values fd call $1 searched for, space-separated.
fd_types() {
  sed -n "${1}p" "$FD_ARGS" | grep -oE -- '--type [a-z]' | cut -c8- | paste -sd' '
}

@test "tmux: sends shell-escaped picks literally to the pane" {
  fzf_returns $'\n\nsrc/a b.py\nEnter'
  pick_in_tmux
  [ "$status" -eq 0 ]
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\nsrc/a\\ b.py Enter ' ]
}

@test "tmux: prefixes picks with @ when the pane runs claude" {
  fzf_returns $'\n\nsrc/a.py\nREADME.md'
  pick_in_tmux PANE_AGENT=claude
  [ "$status" -eq 0 ]
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\n@src/a.py @README.md ' ]
}

@test "tmux: searches the pane's directory" {
  fzf_returns $'\n\na.py'
  pick_in_tmux
  assert_searched 1 "$PANE_DIR"
}

@test "herdr: sends shell-escaped picks to the active pane" {
  fzf_returns $'\n\nsrc/a b.py'
  pick_in_herdr
  [ "$status" -eq 0 ]
  [ "$(cat "$SENT")" = $'w1:p2\nsrc/a\\ b.py ' ]
}

@test "herdr: prefixes picks with @ when the pane runs claude" {
  fzf_returns $'\n\nsrc/a.py\nREADME.md'
  pick_in_herdr PANE_AGENT=claude
  [ "$status" -eq 0 ]
  [ "$(cat "$SENT")" = $'w1:p2\n@src/a.py @README.md ' ]
}

@test "herdr: searches the pane's foreground directory" {
  fzf_returns $'\n\na.py'
  pick_in_herdr
  assert_searched 1 "$PANE_DIR"
}

@test "cancelling fzf sends nothing" {
  pick_in_tmux
  [ "$status" -eq 0 ]
  [ ! -e "$SENT" ]
}

@test "enter with nothing matched sends nothing" {
  fzf_returns $'zzz\n'
  fzf_status 1 1
  pick_in_tmux
  [ "$status" -eq 0 ]
  [ ! -e "$SENT" ]
}

@test "fails outside tmux and herdr" {
  cd "$BATS_TEST_TMPDIR"
  run env -u TMUX -u HERDR_ACTIVE_PANE_ID bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"tmux or herdr"* ]]
}

@test "alt-u searches the parent; picks outside the pane dir are absolute" {
  fzf_returns $'\nalt-u\nx' $'\n\nother.txt'
  pick_in_tmux
  assert_searched 2 "$REPO"
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\n'"$REPO/other.txt " ]
}

@test "alt-u: picks under the pane dir stay relative" {
  fzf_returns $'\nalt-u\nx' $'\n\nproject/sub/a.py'
  pick_in_tmux
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\nsub/a.py ' ]
}

@test "alt-u works when nothing matched" {
  fzf_returns $'zzz\nalt-u' $'\n\nother.txt'
  fzf_status 1 1
  pick_in_tmux
  assert_searched 2 "$REPO"
}

@test "alt-g searches the repo root" {
  fzf_returns $'\nalt-g\nx' $'\n\na.py'
  pick_in_tmux
  assert_searched 2 "$REPO"
}

@test "alt-g outside a repo stays put" {
  rm -rf "$REPO/.git"
  fzf_returns $'\nalt-g\nx' $'\n\na.py'
  pick_in_tmux
  assert_searched 2 "$PANE_DIR"
}

@test "alt-o searches the highlighted file's directory" {
  fzf_returns $'\nalt-o\nsub/a.py' $'\n\nb.py'
  pick_in_tmux
  assert_searched 2 "$PANE_DIR/sub"
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\nsub/b.py ' ]
}

@test "alt-. returns to the pane's directory" {
  fzf_returns $'\nalt-u\nx' $'\nalt-.\nx' $'\n\na.py'
  pick_in_tmux
  assert_searched 3 "$PANE_DIR"
}

@test "alt-r searches the directory cdr-pick prints" {
  stub cdr-pick "echo '$ELSEWHERE'"
  fzf_returns $'\nalt-r\nx' $'\n\nnote.md'
  pick_in_tmux PANE_AGENT=claude
  assert_searched 2 "$ELSEWHERE"
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\n'"@$ELSEWHERE/note.md " ]
}

@test "alt-r: cancelling cdr-pick stays put" {
  stub cdr-pick 'exit 130'
  fzf_returns $'\nalt-r\nx' $'\n\na.py'
  pick_in_tmux
  assert_searched 2 "$PANE_DIR"
}

@test "keeps the query when switching directories" {
  fzf_returns $'needle\nalt-u\nx' $'\n\na.py'
  pick_in_tmux
  fzf_args 2 | grep -qxF needle
}

@test "labels the border with the search directory" {
  fzf_returns $'\n\na.py'
  pick_in_tmux
  fzf_args 1 | grep -qxF ' ~/repo/project · files '
}

@test "ctrl-t cycles files, dirs, both, then back to files" {
  fzf_returns $'\nctrl-t\nx' $'\nctrl-t\nx' $'\nctrl-t\nx' $'\n\na.py'
  pick_in_tmux
  local n types=(f d 'f d' f) labels=(files dirs both files)
  for n in 1 2 3 4; do
    [ "$(fd_types "$n")" = "${types[n - 1]}" ]
    fzf_args "$n" | grep -qxF " ~/repo/project · ${labels[n - 1]} "
  done
}

@test "ctrl-t keeps the query and search directory" {
  fzf_returns $'needle\nalt-u\nx' $'needle\nctrl-t\nx' $'\n\na.py'
  pick_in_tmux
  assert_searched 3 "$REPO"
  fzf_args 3 | grep -qxF needle
}

@test "the mode survives switching directories" {
  fzf_returns $'\nctrl-t\nx' $'\nalt-u\nx' $'\n\na.py'
  pick_in_tmux
  [ "$(fd_types 3)" = d ]
}

@test "alt-o on a directory searches inside it" {
  fzf_returns $'\nctrl-t\nx' $'\nalt-o\nsub/' $'\n\nb.py'
  pick_in_tmux
  assert_searched 3 "$PANE_DIR/sub"
}

@test "alt-s sends the pane's directory as ./" {
  fzf_returns $'\nalt-s\nx'
  pick_in_tmux PANE_AGENT=claude
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\n@./ ' ]
}

@test "alt-s sends a search dir under the pane's dir relative to it" {
  fzf_returns $'\nalt-o\nsub/a.py' $'\nalt-s\nx'
  pick_in_tmux
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\nsub/ ' ]
}

@test "alt-s sends a search dir outside the pane's dir as absolute" {
  fzf_returns $'\nalt-u\nx' $'\nalt-s\nx'
  pick_in_tmux
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\n'"$REPO/ " ]
}

@test "alt-s works when nothing matched" {
  fzf_returns $'zzz\nalt-s'
  fzf_status 1 1
  pick_in_tmux
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\n./ ' ]
}
