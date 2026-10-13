# Shared stubs for bats tests. Load with `load test_helper`.

# Put a stub dir first on PATH; stub() writes executables into it.
setup_stubs() {
  STUBS="$BATS_TEST_TMPDIR/bin"
  FZF_DIR="$BATS_TEST_TMPDIR/fzf"
  mkdir -p "$STUBS" "$FZF_DIR"
  export PATH="$STUBS:$PATH" FZF_DIR
  # Each call N records its args (NUL-separated) and cwd, then prints
  # whatever fzf_returns gave it, or exits like a cancelled fzf.
  stub fzf '
    n=$(( $(cat "$FZF_DIR/calls" 2>/dev/null || echo 0) + 1 ))
    echo "$n" >"$FZF_DIR/calls"
    printf "%s\0" "$@" >"$FZF_DIR/args.$n"
    pwd >"$FZF_DIR/cwd.$n"
    [ -p /dev/stdin ] && cat >/dev/null
    [ -e "$FZF_DIR/out.$n" ] || exit 130
    cat "$FZF_DIR/out.$n"'
}

# Write an executable stub named $1 whose body is $2.
stub() {
  printf '#!/usr/bin/env bash\n%s\n' "$2" >"$STUBS/$1"
  chmod +x "$STUBS/$1"
}

# Set what successive fzf calls print, one argument per call.
fzf_returns() {
  local n=1 out
  for out in "$@"; do
    printf '%s\n' "$out" >"$FZF_DIR/out.$n"
    n=$((n + 1))
  done
}

# Print the args fzf call $1 received, one per line.
fzf_args() {
  tr '\0' '\n' <"$FZF_DIR/args.$1"
}
