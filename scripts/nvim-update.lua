-- Sync lazy.nvim plugins and Mason tools headlessly (make update): prints only
-- what changed and what failed, not every task of every plugin.
local h = require("lazy.core.config").options.headless
h.process, h.task, h.log = false, false, false
require("lazy").sync({ wait = true, show = false })
for _, p in pairs(require("lazy.core.config").plugins) do
  local u = p._.updated
  if u and u.from ~= u.to then io.write(("  %s %s..%s\n"):format(p.name, u.from:sub(1, 7), u.to:sub(1, 7))) end
  for _, t in ipairs(p._.tasks or {}) do
    if t:has_errors() then io.write(("  ✗ %s: %s\n"):format(p.name, t:status() or t.name)) end
  end
end
vim.cmd("MasonToolsUpdateSync")
