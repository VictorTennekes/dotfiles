-- Sync vim.pack plugins, treesitter parsers and Mason tools headlessly (make
-- update): prints only what changed and what failed.
local function revs()
  local r = {}
  for _, p in ipairs(vim.pack.get(nil, { info = false })) do r[p.spec.name] = p.rev end
  return r
end
local before = revs()
-- Progress echoes are scheduled: flush them (vim.wait) while still silent.
vim.cmd("silent lua vim.pack.update(nil, { force = true }) vim.wait(0)")
for name, rev in pairs(revs()) do
  local old = before[name]
  if old and old ~= rev then io.write(("  %s %s..%s\n"):format(name, old:sub(1, 7), rev:sub(1, 7))) end
end
-- main-branch parsers must match the plugin version after every update.
local ts = require("nvim-treesitter")
ts.install(require("plugins.treesitter")):wait(300000)
ts.update():wait(300000)
require("plugins.lspconfig")() -- mason + mason-tool-installer aren't loaded headless
vim.cmd("MasonToolsUpdateSync")
