#!/usr/bin/env bash
# Create a git worktree workspace and make the attached client follow it.
# Bound to prefix+shift+g in ~/.config/herdr/config.toml, replacing herdr's
# built-in new_worktree dialog.
#
# Why: on herdr 0.9.0 the built-in dialog creates the workspace and focuses it
# server-side, but the attached client keeps rendering the workspace you were on
# roughly half the time. Creating over the socket API with --focus and then
# re-issuing workspace.focus makes the client follow every time.
set -uo pipefail

command -v herdr >/dev/null 2>&1 || exit 0

# Popups get HERDR_ACTIVE_PANE_ID (the tiled pane underneath), panes get HERDR_PANE_ID.
pane=${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}
workspace=${pane%%:*}

printf 'new worktree — branch name\n(empty: herdr generates one, ctrl+c: cancel)\n> '
IFS= read -r branch

args=(worktree create --focus)
[[ -n $workspace ]] && args+=(--workspace "$workspace")
[[ -n $branch ]] && args+=(--branch "$branch")

if ! resp=$(herdr "${args[@]}" 2>&1) || ! jq -e 'has("result")' >/dev/null 2>&1 <<<"$resp"; then
    printf '\nworktree create failed:\n%s\n\npress any key… ' "$resp"
    IFS= read -rsn1 _
    exit 1
fi

# Belt and braces: the create already asked for focus, this one lands after the
# new workspace exists, which is the update the client reliably applies.
id=$(jq -r '.result.workspace.workspace_id // empty' <<<"$resp")
[[ -n $id ]] && herdr workspace focus "$id" >/dev/null 2>&1
exit 0
