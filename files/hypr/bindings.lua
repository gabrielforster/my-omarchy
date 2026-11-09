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
--   SUPER + 1..0              Switch to workspace       } shared across monitors
--   SUPER + SHIFT + 1..0      Move window to workspace  } as in i3; Omarchy 4.5
--                                                         made them per monitor,
--                                                         undone in workspaces.lua
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
o.rebind("SUPER + SPACE", "Focus tiling/floating toggle", scripts .. "/hypr-focus-mode-toggle.sh")

-- i3: `$mod+d` launcher (was rofi). Omarchy's menu is also its app launcher.
-- SUPER + D was unbound in Omarchy, so nothing is lost.
o.bind("SUPER + D", "Omarchy menu", { menu = "root" })

-- i3: `$mod+p` screenshot (was flameshot gui).
-- WAS: Pseudo window (dwindle mode where a tiled window floats at tile size).
-- Dropped, not relocated. PRINT still takes a full screenshot.
o.rebind("SUPER + P", "Screenshot region", "omarchy-capture-screenshot region")

-- i3: `$mod+Shift+space` floating toggle.
-- WAS: Toggle top bar -> moved to SUPER + T (below).
o.rebind("SUPER + SHIFT + SPACE", "Toggle window floating/tiling", hl.dsp.window.float({ action = "toggle" }))

-- WAS: Toggle window floating/tiling -> moved to SUPER + SHIFT + SPACE above.
-- Takes over the top bar toggle displaced from SUPER + SHIFT + SPACE.
hl.unbind("SUPER + T")
o.bind_toggle("SUPER + T", "Toggle top bar", "bar")

-- Pairs with SUPER + P above: same region select, but OCRs the selection to
-- the clipboard instead of saving an image. SUPER + CTRL + PRINT still does it.
-- WAS: Google Photos webapp (photos.google.com). Dropped.
o.rebind("SUPER + SHIFT + P", "Extract text (OCR) from screenshot", "omarchy-capture-text")

-- i3: `$mod+Shift+c` reload config. In Hyprland reload and restart are the
-- same operation, so i3's `$mod+Shift+r` (restart) is bound to it too.
-- WAS: Calendar webapp (app.hey.com/calendar). Dropped.
o.rebind("SUPER + SHIFT + C", "Reload Hyprland config", "hyprctl reload")
o.bind("SUPER + SHIFT + R", "Reload Hyprland config", "hyprctl reload")

-- i3: `$mod+Shift+e` exit session (i3-nagbar confirm).
-- WAS: Email webapp (app.hey.com). Dropped.
-- Omarchy's system menu is the confirm-style logout/reboot/shutdown dialog.
-- SUPER + ESCAPE still opens it too.
o.rebind("SUPER + SHIFT + E", "System menu", { menu = "system" })

-- i3: `$mod+Shift+x` lock screen (was i3lock).
-- WAS: X/Twitter webapp (x.com). Dropped.
-- SUPER + CTRL + L still locks as well.
o.rebind("SUPER + SHIFT + X", "Lock system", "omarchy-system-lock")

-- i3: `$mod+o` launch OBS. SUPER + O itself stays as Omarchy's
-- "pop window out", so OBS lands on SHIFT.
-- WAS: Obsidian webapp. Dropped.
o.rebind("SUPER + SHIFT + O", "OBS", { launch = "obs", focus = "^com.obsproject.Studio$" })


-- i3: `$mod+Shift+q` kill window. SUPER + W and SUPER + Q still work too.
-- WAS: Calculator (omacalc), new in Omarchy 4.5 (it moved here from
-- SUPER + CTRL + Q). XF86Calculator still opens it.
o.rebind("SUPER + SHIFT + Q", "Close window", hl.dsp.window.close())


-- ---------------------------------------------------------------------------
-- NEW BINDINGS — these keys were unbound in Omarchy, nothing displaced.
-- ---------------------------------------------------------------------------

-- i3: `$mod+n` file manager. Omarchy's SUPER + SHIFT + F still works too.
o.bind("SUPER + N", "File manager", { omarchy = "nautilus" })

-- i3: `$mod+e` toggle split. Omarchy's SUPER + J still works too.
o.bind("SUPER + E", "Toggle window split", hl.dsp.layout("togglesplit"))

-- i3: `$mod+h` / `$mod+v` set the split direction for the NEXT window.
-- Hyprland's dwindle calls this "preselect": h -> new window to the right,
-- v -> new window below. SUPER + SHIFT + V went to the clipboard history
-- (below), so the vertical preselect takes bare SUPER + V, replacing
-- Omarchy's universal paste there (CTRL + V still pastes everywhere).
-- The horizontal one stays on SHIFT for now; bare SUPER + H is free if the
-- pair should ever be symmetric again.
o.bind("SUPER + SHIFT + H", "Split horizontal (next window right)", hl.dsp.layout("preselect r"))
o.rebind("SUPER + V", "Split vertical (next window below)", hl.dsp.layout("preselect d"))

-- Clipboard history on SUPER + SHIFT + V. Omarchy binds this to
-- SUPER + CTRL + V by default; that binding is left in place as well.
o.bind("SUPER + SHIFT + V", "Clipboard manager", { panel = "omarchy.clipboard" })


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
--       Dwindle has no focusable parent container. SUPER + A is Omarchy's
--       universal "select all" since 4.5.
--
--   $mod+s  layout stacking
--   $mod+w  layout tabbed
--       Dwindle has no stacking/tabbed layouts. The real equivalent is
--       window groups: SUPER + G toggles grouping and draws a tab bar,
--       SUPER + CTRL + LEFT/RIGHT moves between grouped windows.
--       SUPER + S stays scratchpad, SUPER + W stays close window.
--       (SUPER + L now cycles the workspace layout: tiling, scrolling,
--       floating.)
--
--   exec dunst / nm-applet / picom / copyq / xss-lock / dex
--       All handled by omarchy-shell and Hyprland natively.
--
--   setxkbmap / xset r rate / .screenlayout script
--       Wayland equivalents live in ~/.config/hypr/input.lua and monitors.lua.
-- ---------------------------------------------------------------------------

-- Dictation keys from before Alt + Space and Right Alt became the defaults
-- (added to the live file by an Omarchy 4.5 migration; kept here so
-- re-running after/06-hypr doesn't drop them).
-- Remove these lines to give the keys back to applications.
if o.dictation_installed and o.dictation_installed() then
  o.bind("SUPER + CTRL + X", "Toggle dictation", "omarchy-dictation toggle")
  o.bind_hold("F9", "Start dictation (push-to-talk)", "omarchy-dictation start", "Stop dictation (push-to-talk)", "omarchy-dictation stop")
end
