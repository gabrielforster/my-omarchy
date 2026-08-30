-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Ported from the i3 config (`exec discord`).
-- copyq is intentionally NOT ported: Omarchy's clipboard history replaces it
-- (SUPER + CTRL + V).
if o.cmd_present("discord") then
  o.launch_on_start("discord")
end

-- The Spotify desktop client is replaced by the quickshell.spotify bar widget
-- (see after/07-plugins), so there is nothing to autostart.
