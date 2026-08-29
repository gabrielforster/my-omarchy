#!/usr/bin/env bash
# herdr counterpart to tmux-sessionizer.sh: fzf-pick a project directory, then
# create or focus a herdr workspace rooted there.
set -euo pipefail

# Kept in sync with tmux-sessionizer.sh.
SEARCH_DIRS=(
    "$HOME/.config"
    "$HOME/Work"
    "$HOME/Work"/*
    "$HOME/Projects"
    "$HOME"
)

if [[ $# -eq 1 ]]; then
    selected=$1
else
    existing=()
    for d in "${SEARCH_DIRS[@]}"; do
        [[ -d $d ]] && existing+=("$d")
    done
    selected=$(find "${existing[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort -u | fzf)
fi

if [[ -z $selected ]]; then
    exit 0
fi

selected_name=$(basename "$selected" | tr . _)

# `herdr workspace list` errors out when no server is running; in that case
# start one, the same way tmux-sessionizer falls back to `tmux new-session`.
resp=$(herdr workspace list 2>/dev/null) || resp=""
if ! jq -e 'has("result")' >/dev/null 2>&1 <<<"$resp"; then
    exec herdr --session "$selected_name"
fi

existing_id=$(jq -r --arg n "$selected_name" \
    '.result.workspaces[]? | select(.label == $n) | .workspace_id' <<<"$resp" | head -1)

if [[ -n $existing_id ]]; then
    herdr workspace focus "$existing_id"
else
    herdr workspace create --cwd "$selected" --label "$selected_name" --focus
fi
