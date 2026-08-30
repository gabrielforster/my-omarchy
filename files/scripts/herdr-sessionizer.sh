#!/usr/bin/env bash
# herdr counterpart to tmux-sessionizer.sh: fzf-pick a project directory, then
# create or focus a herdr WORKSPACE rooted there.
#
# Herdr's model maps tmux's session onto a workspace, not onto a herdr session:
#   tmux session -> herdr workspace
#   tmux window  -> herdr tab
#   tmux pane    -> herdr pane
# A herdr "session" is a whole separate server with its own socket, so
# `herdr --session <project>` would fragment every project into its own
# detached server. Everything here stays inside the one default session.
#
# Behaviour is identical inside and outside herdr: ensure the server is up,
# create-or-focus the workspace, and attach only if we are not already in it.
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

[[ -z $selected ]] && exit 0

selected_name=$(basename "$selected" | tr . _)

# Panes inherit the caller's directory, and it makes `--cwd` agree with where
# the shell already is.
cd "$selected" || exit 1

server_up() { herdr workspace list >/dev/null 2>&1; }

if ! server_up; then
    # Start the server headless so the workspace can be created with the right
    # label and cwd BEFORE anything attaches. Falls back to a plain attach if
    # this build will not run detached.
    herdr server >/dev/null 2>&1 &
    for _ in $(seq 1 50); do
        server_up && break
        sleep 0.1
    done
    server_up || exec herdr
fi

resp=$(herdr workspace list 2>/dev/null)
existing_id=$(jq -r --arg n "$selected_name" \
    '.result.workspaces[]? | select(.label == $n) | .workspace_id' <<<"$resp" | head -1)

if [[ -n $existing_id ]]; then
    herdr workspace focus "$existing_id" >/dev/null
else
    herdr workspace create --cwd "$selected" --label "$selected_name" --focus >/dev/null
fi

# Inside herdr the workspace is already on screen. Outside, attach to show it.
[[ ${HERDR_ENV:-} == 1 ]] || exec herdr
