-- ===========================================================================
-- i3 keybinding port (from github.com/gabrielforster/i3)
--
-- See current bindings and descriptions:
--   omarchy menu keybindings --print
-- ===========================================================================

local scripts = os.getenv("HOME") .. "/.config/scripts"

-- ---------------------------------------------------------------------------
-- ALREADY IDENTICAL — Omarchy's defaults match i3, nothing bound here.
--
--   SUPER + RETURN            Terminal        (opens ghostty via
--                                              `omarchy default terminal ghostty`)
--   SUPER + F                 Fullscreen
--   SUPER + ARROWS            Focus left/down/up/right
--   SUPER + SHIFT + ARROWS    Move (swap) window
--   SUPER + 1..0              Switch to workspace
--   SUPER + SHIFT + 1..0      Move window to workspace
--   XF86Audio* / XF86MonBrightness*  Volume, media, brightness
--                             (Omarchy's are strictly better: they also
--                              cover mic mute, per-1% steps and OSD)
-- ---------------------------------------------------------------------------


-- ---------------------------------------------------------------------------
-- REBINDS — each unbinds an Omarchy default first. What was lost, and where
-- that function now lives, is noted on every one.
-- ---------------------------------------------------------------------------

-- i3: `focus mode_toggle` (jump between the tiling and floating stacks).
-- WAS: Omarchy menu -> moved to SUPER + D (below).
-- Hyprland has no native equivalent, so this calls a helper script.
hl.unbind("SUPER + SPACE")
o.bind("SUPER + SPACE", "Focus tiling/floating toggle", scripts .. "/hypr-focus-mode-toggle.sh")

-- i3: `$mod+d` launcher (was rofi). Omarchy's menu is also its app launcher.
-- SUPER + D was unbound in Omarchy, so nothing is lost.
o.bind("SUPER + D", "Omarchy menu", "omarchy-menu toggle")

-- i3: `$mod+p` screenshot (was flameshot gui).
-- WAS: Pseudo window (dwindle mode where a tiled window floats at tile size).
-- Dropped, not relocated. PRINT still takes a full screenshot.
hl.unbind("SUPER + P")
o.bind("SUPER + P", "Screenshot region", "omarchy-capture-screenshot region")

-- i3: `$mod+Shift+space` floating toggle.
-- WAS: Toggle top bar -> moved to SUPER + T (below).
hl.unbind("SUPER + SHIFT + SPACE")
o.bind("SUPER + SHIFT + SPACE", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- WAS: Toggle window floating/tiling -> moved to SUPER + SHIFT + SPACE above.
-- Takes over the top bar toggle displaced from SUPER + SHIFT + SPACE.
hl.unbind("SUPER + T")
o.bind_toggle("SUPER + T", "Toggle top bar", "bar")

-- i3: `$mod+Shift+c` reload config. In Hyprland reload and restart are the
-- same operation, so i3's `$mod+Shift+r` (restart) is bound to it too.
-- WAS: Calendar webapp (app.hey.com/calendar). Dropped.
hl.unbind("SUPER + SHIFT + C")
o.bind("SUPER + SHIFT + C", "Reload Hyprland config", "hyprctl reload")
o.bind("SUPER + SHIFT + R", "Reload Hyprland config", "hyprctl reload")

-- i3: `$mod+Shift+e` exit session (i3-nagbar confirm).
-- WAS: Email webapp (app.hey.com). Dropped.
-- Omarchy's system menu is the confirm-style logout/reboot/shutdown dialog.
-- SUPER + ESCAPE still opens it too.
hl.unbind("SUPER + SHIFT + E")
o.bind("SUPER + SHIFT + E", "System menu", "omarchy-menu toggle system")

-- i3: `$mod+Shift+x` lock screen (was i3lock).
-- WAS: X/Twitter webapp (x.com). Dropped.
-- SUPER + CTRL + L still locks as well.
hl.unbind("SUPER + SHIFT + X")
o.bind("SUPER + SHIFT + X", "Lock system", "omarchy-system-lock")

-- i3: `$mod+o` launch OBS. SUPER + O itself stays as Omarchy's
-- "pop window out", so OBS lands on SHIFT.
-- WAS: Obsidian webapp. Dropped.
hl.unbind("SUPER + SHIFT + O")
o.bind("SUPER + SHIFT + O", "OBS", { launch = "obs", focus = "^com.obsproject.Studio$" })


-- ---------------------------------------------------------------------------
-- NEW BINDINGS — these keys were unbound in Omarchy, nothing displaced.
-- ---------------------------------------------------------------------------

-- i3: `$mod+Shift+q` kill window. Omarchy's SUPER + W still works too.
o.bind("SUPER + SHIFT + Q", "Close window", hl.dsp.window.close())

-- i3: `$mod+n` file manager. Omarchy's SUPER + SHIFT + F still works too.
o.bind("SUPER + N", "File manager", { omarchy = "nautilus" })

-- i3: `$mod+e` toggle split. Omarchy's SUPER + J still works too.
o.bind("SUPER + E", "Toggle window split", hl.dsp.layout("togglesplit"))

-- i3: `$mod+h` / `$mod+v` set the split direction for the NEXT window.
-- Hyprland's dwindle calls this "preselect": h -> new window to the right,
-- v -> new window below. SUPER + H/V are Omarchy's universal cut/paste, so
-- these sit on SHIFT.
o.bind("SUPER + SHIFT + H", "Split horizontal (next window right)", hl.dsp.layout("preselect r"))
o.bind("SUPER + SHIFT + V", "Split vertical (next window below)", hl.dsp.layout("preselect d"))


-- ---------------------------------------------------------------------------
-- RESIZE MODE — i3's `$mod+r` submap, same keys (j/k/l/ccedilla + arrows,
-- Return/Escape to leave).
-- ---------------------------------------------------------------------------

hl.define_submap("resize", "reset", function()
  local function grow(x, y)
    return hl.dsp.window.resize({ x = x, y = y, relative = true })
  end

  hl.bind("J", grow(-40, 0), { description = "Shrink width" })
  hl.bind("K", grow(0, 40), { description = "Grow height" })
  hl.bind("L", grow(0, -40), { description = "Shrink height" })
  hl.bind("ccedilla", grow(40, 0), { description = "Grow width" })

  hl.bind("LEFT", grow(-40, 0), { description = "Shrink width" })
  hl.bind("DOWN", grow(0, 40), { description = "Grow height" })
  hl.bind("UP", grow(0, -40), { description = "Shrink height" })
  hl.bind("RIGHT", grow(40, 0), { description = "Grow width" })

  hl.bind("RETURN", hl.dsp.submap("reset"), { description = "Leave resize mode" })
  hl.bind("ESCAPE", hl.dsp.submap("reset"), { description = "Leave resize mode" })
  hl.bind("SUPER + R", hl.dsp.submap("reset"), { description = "Leave resize mode" })
end)

o.bind("SUPER + R", "Resize mode", hl.dsp.submap("resize"))


-- ---------------------------------------------------------------------------
-- NOT PORTED — i3 concepts with no Hyprland equivalent.
--
--   $mod+a  focus parent
--       Dwindle has no focusable parent container. Left unbound.
--
--   $mod+s  layout stacking
--   $mod+w  layout tabbed
--       Dwindle has no stacking/tabbed layouts. The real equivalent is
--       window groups: SUPER + G toggles grouping and draws a tab bar,
--       SUPER + CTRL + LEFT/RIGHT moves between grouped windows.
--       SUPER + S stays scratchpad, SUPER + W stays close window.
--
--   exec dunst / nm-applet / picom / copyq / xss-lock / dex
--       All handled by omarchy-shell and Hyprland natively.
--
--   setxkbmap / xset r rate / .screenlayout script
--       Wayland equivalents live in ~/.config/hypr/input.lua and monitors.lua.
-- ---------------------------------------------------------------------------
