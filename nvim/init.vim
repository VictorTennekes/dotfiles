" Installing plugins
call plug#begin('~/.config/nvim/plugged')

Plug	'mhinz/vim-startify'
Plug	'liuchengxu/vim-which-key'
Plug	'sheerun/vim-polyglot'
Plug	'joshdick/onedark.vim'
Plug	'itchyny/lightline.vim'
Plug	'junegunn/fzf'
Plug	'junegunn/fzf.vim'
Plug	'frazrepo/vim-rainbow'
Plug	'preservim/nerdtree'
Plug	'preservim/nerdcommenter'
Plug	'jiangmiao/auto-pairs'
Plug	'airblade/vim-gitgutter'
Plug	'ryanoasis/vim-devicons'
Plug	'justinmk/vim-sneak'
Plug	'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

set wildmenu
set number relativenumber
let g:sneak#label = 1

" Enable mouse
set mouse=a

" NeoVim and Lightline theme
let g:lightline = { 'colorscheme': 'onedark' }
let g:onedark_termcolors=256
set termguicolors

if (has("autocmd") && !has("gui_running"))
  augroup colorset
    autocmd!
    let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
    autocmd ColorScheme * call onedark#set_highlight("Normal", { "fg": s:white }) " `bg` will not be styled since there is no `bg` setting
  augroup END
endif

colorscheme onedark

" Make clipboard word interchangable between applications and vim
set clipboard+=unnamedplus

" Enabling syntax highlighting and row numbers
set syntax
set number

" Enabling filetype plugins
filetype plugin on

" Indent guides
set list lcs=tab:\|\ 

" NERDTree visuals
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1

" Keymaps
" Mapping Rainbow to Ctrl+r
map <C-r> :RainbowToggle<CR>

" Mapping NERDTreeFocus
map <C-n> :NERDTreeToggle<CR>

" Remapping the leader key to space
:let mapleader = " "

" Mapping leader without anything else to whichkey
nnoremap <silent> <leader> :WhichKey '<Space>'<CR>

map <leader>f :FZF<CR>
