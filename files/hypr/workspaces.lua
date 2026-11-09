-- ---------------------------------------------------------------------------
-- Shared workspaces across monitors (i3 / pre-Omarchy-4.5 behaviour).
--
-- Omarchy 4.5 gave every monitor its own workspaces 1-10
-- (/usr/share/omarchy/default/hypr/monitor-workspaces.lua): each monitor owns
-- a block of ten Hyprland ids (laptop 1-10, next monitor 11-20, ...) and
-- SUPER + 1..0 goes to a slot in the *focused monitor's* block. There is no
-- setting to turn that off, so this file undoes it:
--
--   * SUPER + 1..0 is global again: workspace 3 is workspace 3 wherever it
--     lives, and pressing it jumps to whichever monitor shows it.
--   * The module's reconcile pass (run on start, config reload and monitor
--     plug/unplug) is replaced. Left on, it renumbers any workspace sitting on
--     a monitor it doesn't "own" into that monitor's block (3 -> 13); the
--     replacement does the reverse, folding anything past 10 into 1-10.
--   * o.workspaces.* is replaced in place rather than only rebinding keys,
--     because the bar's workspace widget dispatches
--     `o.workspaces.focus(slot, monitor)` through hyprctl when clicked or
--     scrolled — it picks up these versions too.
--
-- The bar decides which ids belong to a monitor from
-- ~/.local/state/omarchy/monitor-workspaces; with that file absent it uses
-- the block of the workspace the monitor shows, which is always 1-10 here.
-- after/06-hypr deletes the file; nothing recreates it while this is loaded.
--
-- To go back to per-monitor workspaces: remove `require("hypr.workspaces")`
-- from hyprland.lua.
-- ---------------------------------------------------------------------------

local ws = o.workspaces
if not ws then
  return
end

-- Same trick the module uses: the keybindings menu replays a function bind
-- through `hyprctl dispatch <expression>`.
local function action(fn, expression)
  o.bind_expressions[fn] = expression
  return fn
end

-- Instead of keeping monitors in their blocks, fold anything numbered past 10
-- back into 1-10: leftovers from a per-monitor session (the external
-- monitor's 11-20) would otherwise sit outside SUPER + 1..0's reach, and the
-- bar would list them as a second "1 2 3 ..." group. A workspace keeps its
-- slot (13 -> 3) when that is free, else takes the first free one. Runs where
-- the module ran its own pass: start, config reload, monitor plug/unplug.
ws.reconcile = function()
  local taken = {}
  local extra = {}
  for _, workspace in ipairs(hl.get_workspaces()) do
    if not workspace.special and workspace.id > 0 then
      if workspace.id <= 10 then
        taken[workspace.id] = true
      else
        extra[#extra + 1] = workspace.id
      end
    end
  end
  table.sort(extra)

  for _, old in ipairs(extra) do
    local wanted = (old - 1) % 10 + 1
    local id = not taken[wanted] and wanted or nil
    for slot = 1, 10 do
      if id then break end
      if not taken[slot] then id = slot end
    end
    if not id then return end -- all ten in use; leave the rest alone

    hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(old), id = id }))
    taken[id] = true
  end
end

ws.workspace_id = function(_, slot)
  return slot
end

ws.focus = function(slot)
  return action(function()
    hl.dispatch(hl.dsp.focus({ workspace = tostring(slot) }))
  end, "o.workspaces.focus(" .. slot .. ")")
end

ws.move_window = function(slot, follow)
  return action(function()
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(slot), follow = follow ~= false }))
  end, "o.workspaces.move_window(" .. slot .. (follow == false and ", false" or "") .. ")")
end

ws.move_to_monitor = function(direction)
  return action(function()
    local target = hl.get_monitor(direction)
    if target then
      hl.dispatch(hl.dsp.workspace.move({ monitor = target.name }))
    end
  end, "o.workspaces.move_to_monitor(" .. string.format("%q", direction) .. ")")
end

-- Omarchy's binds captured the per-monitor closures when tiling.lua loaded,
-- so they have to be bound again to pick up the versions above.
for slot = 1, 10 do
  local key = "code:" .. tostring(slot + 9)
  o.rebind("SUPER + " .. key, "Switch to workspace " .. slot, ws.focus(slot))
  o.rebind("SUPER + SHIFT + " .. key, "Move window to workspace " .. slot, ws.move_window(slot))
  o.rebind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. slot, ws.move_window(slot, false))
end

for dir, name in pairs({ l = "left", r = "right", u = "up", d = "down" }) do
  o.rebind("SUPER + SHIFT + ALT + " .. name:upper(), "Move workspace to " .. name .. " monitor", ws.move_to_monitor(dir))
end

-- 4.5 made these stay on the current monitor (m+1 / previous_per_monitor).
-- Back to walking every existing workspace, wherever it is.
o.rebind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
o.rebind("SUPER + SHIFT + TAB", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
o.rebind("SUPER + CTRL + TAB", "Former workspace", hl.dsp.focus({ workspace = "previous" }))
o.rebind("SUPER + mouse_down", "Scroll active workspace forward", hl.dsp.focus({ workspace = "e+1" }))
o.rebind("SUPER + mouse_up", "Scroll active workspace backward", hl.dsp.focus({ workspace = "e-1" }))
