#!/usr/bin/env bash

# where tmux-resurrect saves its snapshots
RES_DIR="${TMUX_RESURRECT_DIR:-"$HOME/.local/share/tmux/resurrect"}"

# make sure fzf is installed
if ! command -v fzf >/dev/null 2>&1; then
  tmux display-message "fzf not found – install it first!"
  exit 1
fi

# format names for selection with fzf.
# I've found it's useful to see the size and timestamp.
chosen=$(
  ls -lt $HOME/.local/share/tmux/resurrect/tmux_*.txt \
      | while read -r _perms _links _owner _group size month day time fullpath; do
          echo "$size $month $day $time $(basename "$fullpath")"
        done \
      | fzf --prompt="Choose which state to restore > " \
      | awk '{print $NF}')
[ -z "$chosen" ] && exit 0

ln -sf "$RES_DIR/$chosen" "$RES_DIR/last"

# hand off to tmux-resurrect’s own restore script
"$HOME/.tmux/plugins/tmux-resurrect/scripts/restore.sh"
