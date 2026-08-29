# Insert the personal plugin widgets after omarchy.tray without disturbing
# anything else in the section, then push omarchy.monitor to the end.
# Idempotent: existing copies are stripped first, so re-running is a no-op.
.bar.layout.right = (
  ( .bar.layout.right
    | map(select(.id as $i | ($ids | index($i)) == null)) ) as $base
  | ( $base | to_entries
            | map(select(.value.id == "omarchy.tray"))
            | (.[0].key // -1) ) as $tray
  | $base[0:($tray+1)] + $entries + $base[($tray+1):]
)
| .bar.layout.right = (
    ( .bar.layout.right | map(select(.id != "omarchy.monitor")) )
  + ( .bar.layout.right | map(select(.id == "omarchy.monitor")) )
)
