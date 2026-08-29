-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- Ported from the i3 config (`exec discord`).
-- copyq is intentionally NOT ported: Omarchy's clipboard history replaces it
-- (SUPER + CTRL + V).
if o.cmd_present("discord") then
  o.launch_on_start("discord")
end

if o.cmd_present("spotify") then
  o.launch_on_start("spotify")
end
