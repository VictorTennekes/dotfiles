vim.g.mapleader = " "

-- Set keybinds for split screen navigation (Ctrl + hjkl)
local opts = { noremap = true, silent = true }

vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Leader keybindings for splits
vim.keymap.set('n', '<leader>vs', ':vsplit<CR>', opts)
vim.keymap.set('n', '<leader>hs', ':split<CR>', opts)
