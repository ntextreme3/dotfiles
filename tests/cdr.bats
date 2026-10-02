# Tests for _cdr_candidates (dot_bashrc.d/base/cdr.sh)
#
# Run: npx bats@1.13.0 tests/

setup() {
  source "$BATS_TEST_DIRNAME/../dot_bashrc.d/base/cdr.sh"
  export HOME=/home/u
  export HISTFILE="$BATS_TEST_TMPDIR/history"
}

# Write args as history lines, oldest first, like ~/.bash_history.
history_of() {
  printf '%s\n' "$@" > "$HISTFILE"
}

# Assert candidates equal args, one per line, in order.
assert_candidates() {
  run _cdr_candidates
  [ "$status" -eq 0 ]
  local expected
  expected=$(printf '%s\n' "$@")
  if [ "$output" != "$expected" ]; then
    printf 'expected:\n%s\nactual:\n%s\n' "$expected" "$output"
    return 1
  fi
}

@test "lists most recent first" {
  history_of 'cd old' 'cd new'
  assert_candidates new old
}

@test "keeps only the most recent occurrence of a dir" {
  history_of 'cd a' 'cd b' 'cd a'
  assert_candidates a b
}

@test "ignores non-cd commands and timestamp lines" {
  history_of '#1700000000' 'cd a' '#1700000001' 'ls -la' 'echo cd b' 'cdr'
  assert_candidates a
}

@test "tolerates leading whitespace and repeated spaces" {
  history_of '  cd   a'
  assert_candidates a
}

@test "strips chained commands" {
  history_of \
    'cd a && make' \
    'cd b || exit' \
    'cd c; ls' \
    'cd d | cat' \
    'cd e&&make'
  assert_candidates e d c b a
}

@test "strips trailing whitespace" {
  history_of 'cd a   ' 'cd a'
  assert_candidates a
}

@test "drops command substitutions" {
  history_of 'cd $(git root)' 'cd a' 'cd $(mktemp -d)'
  assert_candidates a
}

@test "drops dot and dash only targets" {
  history_of 'cd a' 'cd .' 'cd ..' 'cd ../..' 'cd -' 'cd ./'
  assert_candidates a
}

@test "collapses ~, \$HOME and relative forms of a home dir" {
  history_of 'cd ~/a' 'cd /home/u/a' 'cd a'
  assert_candidates a
}

@test "keeps dirs outside \$HOME absolute" {
  history_of 'cd /tmp/x'
  assert_candidates /tmp/x
}

@test "strips leading ../ segments" {
  history_of 'cd ../../a/b'
  assert_candidates a/b
}

@test "strips trailing slashes" {
  history_of 'cd a//' 'cd a'
  assert_candidates a
}

@test "caps output at 1000 dirs" {
  # not `lines`: bats' `run` overwrites it with the output lines
  local i cds=()
  for i in $(seq 1 1001); do cds+=("cd d$i"); done
  history_of "${cds[@]}"
  run _cdr_candidates
  [ "${#lines[@]}" -eq 1000 ]
  # the oldest dir is the one cut
  [ "${lines[999]}" = d2 ]
}

@test "prints nothing when the history file is missing" {
  rm -f "$HISTFILE"
  assert_candidates
}
