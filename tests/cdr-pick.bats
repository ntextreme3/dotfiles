# Tests for dot_local/bin/executable_cdr-pick and the cdr wrapper around it
#
# fzf is stubbed; see test_helper.bash.
#
# Run: prek run bats --all-files

load test_helper

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../dot_local/bin/executable_cdr-pick"
  setup_stubs
  export HOME="$BATS_TEST_TMPDIR/home"
  mkdir -p "$HOME/src/proj"
  cd "$BATS_TEST_TMPDIR"
}

@test "ctrl-d prints a home-relative pick under \$HOME" {
  fzf_returns $'ctrl-d\nsrc/proj'
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/src/proj" ]
}

@test "ctrl-d prints an absolute pick as-is" {
  fzf_returns $'ctrl-d\n/tmp/x'
  run bash "$SCRIPT"
  [ "$output" = /tmp/x ]
}

@test "ctrl-d prints a pick missing from \$HOME as given" {
  fzf_returns $'ctrl-d\nelsewhere'
  run bash "$SCRIPT"
  [ "$output" = elsewhere ]
}

@test "enter locates the pick with a second fzf and prints its choice" {
  fzf_returns $'\nsrc/proj' "$HOME/src/proj"
  run bash "$SCRIPT"
  [ "$status" -eq 0 ]
  [ "$output" = "$HOME/src/proj" ]
  fzf_args 2 | grep -qxF "'proj/'"
}

@test "passes its argument as the initial query" {
  run bash "$SCRIPT" proj
  fzf_args 1 | grep -qxF proj
}

@test "cancelling prints nothing and fails" {
  run bash "$SCRIPT"
  [ "$status" -ne 0 ]
  [ -z "$output" ]
}

@test "cdr changes to the directory cdr-pick prints" {
  stub cdr-pick "echo '$HOME/src/proj'"
  source "$BATS_TEST_DIRNAME/../dot_bashrc.d/base/cdr.sh"
  cdr
  [ "$PWD" = "$HOME/src/proj" ]
}

@test "cdr stays put when cdr-pick prints nothing" {
  stub cdr-pick 'exit 1'
  source "$BATS_TEST_DIRNAME/../dot_bashrc.d/base/cdr.sh"
  cdr || true
  [ "$PWD" = "$BATS_TEST_TMPDIR" ]
}
