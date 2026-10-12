# Tests for dot_local/bin/executable_file-picker
#
# tmux, herdr, fd, fzf and pgrep are replaced by stubs on PATH. The stubs log
# what the picker asked of them so tests can check what reached the pane.
#
# Run: prek run bats --all-files

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../dot_local/bin/executable_file-picker"
  STUBS="$BATS_TEST_TMPDIR/bin"
  SENT="$BATS_TEST_TMPDIR/sent"
  FD_CWD="$BATS_TEST_TMPDIR/fd-cwd"
  PANE_DIR="$BATS_TEST_TMPDIR/project"
  mkdir -p "$STUBS" "$PANE_DIR"

  # Records the directory fd searched; the file list itself comes from fzf.
  stub fd 'pwd >"$FD_CWD"'
  # Prints $FZF_PICKS as the selection, or exits like a cancelled fzf.
  stub fzf 'cat >/dev/null; [ -n "${FZF_PICKS-}" ] || exit 130; printf "%s\n" "${FZF_PICKS[@]}" | tr "|" "\n"'
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

# Write an executable stub named $1 whose body is $2.
stub() {
  printf '#!/usr/bin/env bash\n%s\n' "$2" >"$STUBS/$1"
  chmod +x "$STUBS/$1"
}

# Run the picker as a tmux popup would: inside tmux, from some other dir.
pick_in_tmux() {
  cd "$BATS_TEST_TMPDIR"
  run env PATH="$STUBS:$PATH" TMUX=/tmp/tmux-sock,1,0 FD_CWD="$FD_CWD" SENT="$SENT" \
    PANE_DIR="$PANE_DIR" "$@" bash "$SCRIPT"
}

# Run the picker as a herdr popup would: no HERDR_PANE_ID, only the active pane.
pick_in_herdr() {
  cd "$BATS_TEST_TMPDIR"
  run env -u TMUX PATH="$STUBS:$PATH" HERDR_ACTIVE_PANE_ID=w1:p2 FD_CWD="$FD_CWD" \
    SENT="$SENT" PANE_DIR="$PANE_DIR" "$@" bash "$SCRIPT"
}

@test "tmux: sends shell-escaped picks literally to the pane" {
  pick_in_tmux FZF_PICKS="src/a b.py|Enter"
  [ "$status" -eq 0 ]
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\nsrc/a\\ b.py Enter ' ]
}

@test "tmux: prefixes picks with @ when the pane runs claude" {
  pick_in_tmux FZF_PICKS="src/a.py|README.md" PANE_AGENT=claude
  [ "$status" -eq 0 ]
  [ "$(cat "$SENT")" = $'-l\n-t\n%7\n@src/a.py @README.md ' ]
}

@test "tmux: searches the pane's directory" {
  pick_in_tmux FZF_PICKS="a.py"
  [ "$(cat "$FD_CWD")" = "$PANE_DIR" ]
}

@test "herdr: sends shell-escaped picks to the active pane" {
  pick_in_herdr FZF_PICKS="src/a b.py"
  [ "$status" -eq 0 ]
  [ "$(cat "$SENT")" = $'w1:p2\nsrc/a\\ b.py ' ]
}

@test "herdr: prefixes picks with @ when the pane runs claude" {
  pick_in_herdr FZF_PICKS="src/a.py|README.md" PANE_AGENT=claude
  [ "$status" -eq 0 ]
  [ "$(cat "$SENT")" = $'w1:p2\n@src/a.py @README.md ' ]
}

@test "herdr: searches the pane's foreground directory" {
  pick_in_herdr FZF_PICKS="a.py"
  [ "$(cat "$FD_CWD")" = "$PANE_DIR" ]
}

@test "cancelling fzf sends nothing" {
  pick_in_tmux
  [ "$status" -eq 0 ]
  [ ! -e "$SENT" ]
}

@test "fails outside tmux and herdr" {
  cd "$BATS_TEST_TMPDIR"
  run env -u TMUX -u HERDR_ACTIVE_PANE_ID PATH="$STUBS:$PATH" bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [[ "$output" == *"tmux or herdr"* ]]
}
