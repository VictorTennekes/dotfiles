-- This file can be loaded by calling `lua require('config.plugins')` from your init.vim

return {
    -- Cheatsheet
    'folke/which-key.nvim',

    -- Completion, LSP & Language plugins
    { 'neoclide/coc.nvim', branch = 'release' },
    'neovim/nvim-lspconfig',
    'sheerun/vim-polyglot',

    -- Visual
    { 'catppuccin/nvim',   as = 'catppuccin' },
    'nvim-lualine/lualine.nvim',

    -- Telescope & dependencies
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.6',
        -- or                            , branch = '0.1.x',
        requires = { { 'nvim-lua/plenary.nvim' } }
    },
    { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' },

    -- Misc
    'nvim-tree/nvim-tree.lua',
    'jiangmiao/auto-pairs',
    'airblade/vim-gitgutter',
    'ryanoasis/vim-devicons',
    'justinmk/vim-sneak',
}
