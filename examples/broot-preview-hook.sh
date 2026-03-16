#!/usr/bin/env bash
set -euo pipefail

selected_path="${1:-}"

if [ -z "${TMUX_PANE:-}" ]; then
  printf 'broot-preview-hook.sh must run inside tmux\n' >&2
  exit 1
fi

session_name="$(tmux display-message -p -t "$TMUX_PANE" '#S')"
selection_output="$(tmux show-options -qv -t "$session_name" @broot_selection_output)"

if [ -z "$selection_output" ]; then
  printf 'missing tmux session option @broot_selection_output in session %s\n' "$session_name" >&2
  exit 1
fi

printf '%s\n' "$selected_path" >"$selection_output"
