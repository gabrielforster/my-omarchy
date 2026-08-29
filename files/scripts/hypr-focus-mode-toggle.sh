#!/usr/bin/env bash
# i3's `focus mode_toggle`: move focus between the tiling and floating stacks
# on the current workspace. Hyprland has no built-in equivalent.
set -euo pipefail

active=$(hyprctl -j activewindow)
ws=$(jq -r '.workspace.id // empty' <<<"$active")
[[ -n $ws ]] || exit 0

# Target the opposite floating state from the window we're on.
if [[ $(jq -r '.floating' <<<"$active") == "true" ]]; then
    want=false
else
    want=true
fi

# Of the candidates, pick the most recently focused (lowest focusHistoryID).
addr=$(hyprctl -j clients | jq -r --argjson ws "$ws" --argjson want "$want" '
    [ .[] | select(.workspace.id == $ws and .floating == $want and .mapped == true) ]
    | sort_by(.focusHistoryID) | .[0].address // empty')
[[ -n $addr ]] || exit 0

hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })"
