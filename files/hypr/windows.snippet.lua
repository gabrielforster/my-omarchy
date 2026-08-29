-- Ported from the i3 config's `assign` rules. "silent" matches i3's behaviour
-- of placing the window without pulling focus to that workspace.
-- The i3 `assign [class="Code"] $ws2` rule was dropped (VS Code no longer used).
o.window("^([Dd]iscord)$", { workspace = "5 silent" })
o.window("^([Ss]potify)$", { workspace = "10 silent" })
