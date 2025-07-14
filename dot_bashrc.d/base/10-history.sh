# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# Ignore certain commands
HISTIGNORE="ls:bg:fg:history:pwd:tmux:rm:cd ..:jobs"

# Show timestamps in history %F=YYYY-MM-DD and %T=HH:MM:SS
HISTTIMEFORMAT='%F %T '

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=-1

# Copy changes to $HISTFILE to a backup file, once per day.
backup_bash_history() {
    # NOTE: This doesn't attempt to sort anything by time.

    if [[ -z "$HISTFILE" ]]; then
        echo "Error: HISTFILE is not set." >&2
        return 1
    fi

    # Skip if we've backed up the history file in the last 24 hours.
    local HIST_BACKUP_FILE="$HOME/.bash_history.golden"
    if [[ -f "$HIST_BACKUP_FILE" && $(find "$HIST_BACKUP_FILE" -mtime -1) ]]; then
        echo "Skipping backup: $HIST_BACKUP_FILE already exists and was updated in the last day." >&2
        return 0
    fi

    # Only create the backup file if it doesn't exist, to avoid updating its mtime unnecessarily.
    if [[ ! -f "$HIST_BACKUP_FILE" ]]; then
        touch "$HIST_BACKUP_FILE"
    fi

    # Find the last command that was backed up
    local LATEST_BACKUP_CMD_TIME=$(grep '^#' "$HIST_BACKUP_FILE" | tail -n 1)
    if [[ -z "$LATEST_BACKUP_CMD_TIME" ]]; then
        # No previous backup timestamp found, copy the whole file
        echo "Warning: No previous backup found. Copying the entire history file to $HIST_BACKUP_FILE." >&2
        cat "$HISTFILE" >> "$HIST_BACKUP_FILE"
        return 0
    fi

    # Find the next timestamp in the history file after the last backup
    local NEXT_TIMESTAMP=$(grep '^#' "$HISTFILE" | grep -A1 -F "$LATEST_BACKUP_CMD_TIME" | tail -n 1)
    if [[ -z "$NEXT_TIMESTAMP" ]]; then
        # NOTE: If `erasedups` is enabled, this likely bloats the backup file.
        echo "Warning: Could not find where we left off in $HISTFILE. Copying the entire history file to $HIST_BACKUP_FILE." >&2
        cat "$HISTFILE" >> "$HIST_BACKUP_FILE"
        return 0
    fi
    if [[ "$NEXT_TIMESTAMP" == "$LATEST_BACKUP_CMD_TIME" ]]; then
        echo "No new commands to append to $HIST_BACKUP_FILE." >&2
        return 0
    fi

    # Get the line number of this next timestamp
    local NEXT_TIMESTAMP_LINE_NUM=$(grep -Fn "$NEXT_TIMESTAMP" "$HISTFILE" | tail -n 1 | cut -d: -f1)

    # Calculate how many lines to append
    local TOTAL_LINES=$(wc -l "$HISTFILE" | awk '{print $1}')
    local NUM_LINES_TO_APPEND=$((TOTAL_LINES - NEXT_TIMESTAMP_LINE_NUM + 1))
    if [[ $NUM_LINES_TO_APPEND -le 0 ]]; then
        echo "No new commands to append to $HIST_BACKUP_FILE." >&2
        return 0
    fi

    # Append the new commands to the backup file
    tail -n "$NUM_LINES_TO_APPEND" "$HISTFILE" >> "$HIST_BACKUP_FILE"
    echo "Appended $NUM_LINES_TO_APPEND lines to $HIST_BACKUP_FILE."
}
backup_bash_history

# Ensure a final write on exit:
# trap 'history -a; history -w' EXIT

