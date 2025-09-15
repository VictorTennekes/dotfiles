require("config.personal")

-- lazy nvim
require("config.lazy")

-- Basic Config
vim.cmd 'runtime vimrc'

-- Visual
require('lualine').setup()

require("catppuccin").setup({
        transparent_background = true
    })

require("nvim-tree").setup({
  renderer = {
    highlight_git = true,  -- enable git highlighting including dimming
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
    ignore = false, -- dim gitignored files instead of hiding
  },
})

do --Appearance
	vim.opt.laststatus = 2

	vim.opt.termguicolors = true
	vim.cmd.colorscheme "catppuccin-mocha"
end
