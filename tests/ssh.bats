# Tests for dot_bashrc.d/base/ssh.sh
#
# These start real ssh-agent processes; teardown stops them.
#
# Run: prek run bats --all-files

setup() {
  SCRIPT="$BATS_TEST_DIRNAME/../dot_bashrc.d/base/ssh.sh"
  FAKE_HOME="$BATS_TEST_TMPDIR/home"
  RUNTIME="$BATS_TEST_TMPDIR/run"
  LINK="$RUNTIME/ssh-agent.sock"
  FALLBACK="$FAKE_HOME/.cache/ssh-agent/$HOSTNAME.sock"
  PIDS="$BATS_TEST_TMPDIR/pids"
  mkdir -p "$FAKE_HOME"
  mkdir -m 700 "$RUNTIME"
}

teardown() {
  # Agents outlive the shells that started them, so stop every one we made.
  if [ -f "$PIDS" ]; then
    while read -r pid; do kill "$pid" 2>/dev/null; done <"$PIDS"
  fi
  true
}

# Source ssh.sh in a clean shell with a fake HOME plus the given env vars, and
# record what it leaves behind in SOCK, TARGET (where the link points),
# NEW_PID (set only if it started an agent) and ADD_STATUS (`ssh-add -l` exit:
# 2 means no agent was reachable). Anything ssh.sh prints lands in $output; the
# state goes to a file so that output can't garble it. The timeout turns a hang
# into a failure.
login() {
  local state="$BATS_TEST_TMPDIR/state"
  run timeout 10 env -i PATH="$PATH" HOME="$FAKE_HOME" \
    TMPDIR="$BATS_TEST_TMPDIR" "$@" bash --norc --noprofile -c '
      source "$1"
      {
        echo "$SSH_AUTH_SOCK"
        echo "$(readlink "$SSH_AUTH_SOCK")"
        echo "${SSH_AGENT_PID-}"
        ssh-add -l >/dev/null 2>&1
        echo $?
      } >"$2"' _ "$SCRIPT" "$state"
  if [ "$status" -ne 0 ]; then
    printf 'login exited with status %s:\n%s\n' "$status" "$output"
    return 1
  fi
  { read -r SOCK; read -r TARGET; read -r NEW_PID; read -r ADD_STATUS; } <"$state"
  if [ -n "$NEW_PID" ]; then echo "$NEW_PID" >>"$PIDS"; fi
}

# Start an agent for the shell under test to inherit, like a forwarded one.
start_other_agent() {
  OTHER_SOCK="$BATS_TEST_TMPDIR/other.sock"
  ssh-agent -a "$OTHER_SOCK" -s | sed -n 's/^SSH_AGENT_PID=\([0-9]*\);.*/\1/p' >>"$PIDS"
}

# Print a socket owned by someone else that we could still connect to: the
# case the ownership check exists for.
foreign_socket() {
  find /run /var/run /tmp -maxdepth 2 -type s ! -user "$(id -u)" -writable 2>/dev/null |
    head -n 1 | grep .
}

@test "starts an agent behind the link on first login" {
  login XDG_RUNTIME_DIR="$RUNTIME"
  [ "$SOCK" = "$LINK" ]
  [ -n "$NEW_PID" ]
  [ -S "$TARGET" ]
  [ "$ADD_STATUS" -ne 2 ]
}

@test "prints nothing when it starts an agent" {
  login XDG_RUNTIME_DIR="$RUNTIME"
  [ -n "$NEW_PID" ]
  [ -z "$output" ]
}

@test "a new terminal reuses the running agent" {
  login XDG_RUNTIME_DIR="$RUNTIME"
  local first=$TARGET
  login XDG_RUNTIME_DIR="$RUNTIME"
  [ "$TARGET" = "$first" ]
  [ -z "$NEW_PID" ]
  [ "$ADD_STATUS" -ne 2 ]
}

@test "a child shell that inherits the link reuses it" {
  login XDG_RUNTIME_DIR="$RUNTIME"
  local first=$TARGET
  login XDG_RUNTIME_DIR="$RUNTIME" SSH_AUTH_SOCK="$LINK"
  [ "$TARGET" = "$first" ]
  [ -z "$NEW_PID" ]
}

@test "a differently spelled link path doesn't point the link at itself" {
  login XDG_RUNTIME_DIR="$RUNTIME"
  local first=$TARGET
  login XDG_RUNTIME_DIR="$RUNTIME/" SSH_AUTH_SOCK="$RUNTIME//ssh-agent.sock"
  [ "$TARGET" = "$first" ]
  [ "$ADD_STATUS" -ne 2 ]
}

@test "an inherited agent takes over the link" {
  login XDG_RUNTIME_DIR="$RUNTIME"
  start_other_agent
  login XDG_RUNTIME_DIR="$RUNTIME" SSH_AUTH_SOCK="$OTHER_SOCK"
  [ "$TARGET" = "$OTHER_SOCK" ]
  [ -z "$NEW_PID" ]
  [ "$ADD_STATUS" -ne 2 ]
}

@test "replaces an agent that has died" {
  login XDG_RUNTIME_DIR="$RUNTIME"
  local first=$TARGET pid=$NEW_PID i
  kill "$pid"
  # Wait for it to exit, or the next login could still reach it.
  for i in $(seq 50); do kill -0 "$pid" 2>/dev/null || break; sleep 0.1; done
  login XDG_RUNTIME_DIR="$RUNTIME"
  [ -n "$NEW_PID" ]
  [ "$TARGET" != "$first" ]
  [ "$ADD_STATUS" -ne 2 ]
}

@test "ignores an inherited socket owned by another user" {
  local foreign
  foreign=$(foreign_socket) || skip "no connectable socket owned by another user"
  login XDG_RUNTIME_DIR="$RUNTIME" SSH_AUTH_SOCK="$foreign"
  [ "$TARGET" != "$foreign" ]
  [ -n "$NEW_PID" ]
}

@test "replaces a link that points at another user's socket" {
  local foreign
  foreign=$(foreign_socket) || skip "no connectable socket owned by another user"
  ln -s "$foreign" "$LINK"
  login XDG_RUNTIME_DIR="$RUNTIME"
  [ "$TARGET" != "$foreign" ]
  [ -n "$NEW_PID" ]
}

@test "falls back to a private per-host link without XDG_RUNTIME_DIR" {
  login
  [ "$SOCK" = "$FALLBACK" ]
  [ "$(ls -ld "$FAKE_HOME/.cache/ssh-agent" | cut -c1-10)" = drwx------ ]
  [ "$ADD_STATUS" -ne 2 ]
}

@test "falls back when XDG_RUNTIME_DIR points at a missing directory" {
  login XDG_RUNTIME_DIR="$BATS_TEST_TMPDIR/missing"
  [ "$SOCK" = "$FALLBACK" ]
  [ "$ADD_STATUS" -ne 2 ]
}
