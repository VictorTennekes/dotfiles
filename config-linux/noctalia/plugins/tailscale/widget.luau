-- Shield in Catppuccin green while connected, Overlay0 grey otherwise.
-- tailscaled only runs while connected (see ./toggle), so a
-- failing `tailscale status` simply means off.
local status_cmd = [[tailscale status --json 2>/dev/null | jq -r '[.BackendState, (.Self.TailscaleIPs[0] // ""), ([.Peer[]? | select(.Online) | (.DNSName | split(".")[0])] | join(", "))] | join("\n")']]
local toggle_cmd = "~/.config/noctalia/plugins/tailscale/toggle"

local function show(state, ip, peers)
  if state == "Running" then
    barWidget.setGlyph("shield-check")
    barWidget.setGlyphColor("#a6e3a1")
    barWidget.setTooltip("Tailscale: connected (" .. ip .. ")\nOnline: " .. (peers ~= "" and peers or "none"))
  else
    barWidget.setGlyph("shield-off")
    barWidget.setGlyphColor("#6c7086")
    barWidget.setTooltip("Tailscale: " .. state .. " (click to connect)")
  end
end

function update()
  noctalia.setUpdateInterval(10000)
  noctalia.runAsync(status_cmd, function(result)
    if result and result.exitCode == 0 and result.stdout ~= "" then
      local lines = {}
      for line in (result.stdout .. "\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
      end
      show(lines[1] or "off", lines[2] or "", lines[3] or "")
    else
      show("off", "", "")
    end
  end)
end

function onClick()
  barWidget.setGlyph("shield")
  barWidget.setGlyphColor("#f9e2af")
  noctalia.runAsync(toggle_cmd, function() update() end)
end

update()
