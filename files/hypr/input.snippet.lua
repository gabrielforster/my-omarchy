-- ---------------------------------------------------------------------------
-- Ported from the i3 config:
--   exec_always setxkbmap -layout us   -> kb_layout below
--   exec_always xset r rate 200 42     -> repeat_delay 200 / repeat_rate 42
-- (Omarchy's defaults were 250ms delay / 40 per second.)
-- ---------------------------------------------------------------------------
hl.config({
  input = {
    kb_layout = "us",
    repeat_delay = 200,
    repeat_rate = 42,
  },
})
