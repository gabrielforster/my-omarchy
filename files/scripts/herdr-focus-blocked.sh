#!/usr/bin/env bash
# Focus the next herdr agent waiting on input: blocked on an approval/question
# dialog, or done with an unseen completion (herdr >= 0.9 reports that as
# "done"; focusing marks it seen, so it drops out of the cycle afterwards).
# Bound to prefix+shift+o in ~/.config/herdr/config.toml.
#
# Unlike open_notification_target (prefix+o), this works whether or not a
# toast is currently on screen, and cycles through every blocked agent.
set -euo pipefail

command -v herdr >/dev/null 2>&1 || exit 0

resp=$(herdr agent list 2>/dev/null) || exit 0
# `herdr agent list` emits {"id":..,"error":{..}} when the server is down.
jq -e 'has("result")' >/dev/null 2>&1 <<<"$resp" || exit 0

# Every waiting agent, blocked ones first, in a stable order so the cycle is
# predictable.
mapfile -t blocked < <(
    jq -r '.result.agents
           | map(select(.agent_status == "blocked" or .agent_status == "done"))
           | sort_by(.agent_status != "blocked", .workspace_id, .pane_id)
           | .[].pane_id' <<<"$resp"
)
(( ${#blocked[@]} )) || exit 0

# Jump to the first blocked agent after the focused one, wrapping around.
current=$(jq -r '.result.agents | map(select(.focused)) | .[0].pane_id // empty' <<<"$resp")
target=${blocked[0]}
for i in "${!blocked[@]}"; do
    if [[ ${blocked[$i]} == "$current" ]]; then
        target=${blocked[$(( (i + 1) % ${#blocked[@]} ))]}
        break
    fi
done

herdr agent focus "$target"
