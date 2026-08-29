#!/usr/bin/env bash

# Directories scanned for projects. Each entry is searched one level deep,
# so ~/Work/<org>/<repo> is reached by listing both ~/Work and ~/Work/*.
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
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

tmux switch-client -t "$selected_name" || tmux attach -t "$selected_name"
