call plug#begin('~/.vim/plugged')

Plug	'sheerun/vim-polyglot'
Plug	'joshdick/onedark.vim'
Plug	'itchyny/lightline.vim'
Plug	'junegunn/fzf'
Plug	'junegunn/fzf.vim'

call plug#end()
let g:lightline = { 'colorscheme': 'onedark' }
let g:onedark_termcolors=256
set termguicolors
colorscheme onedark
set clipboard+=unnamedplus
set syntax
set number
