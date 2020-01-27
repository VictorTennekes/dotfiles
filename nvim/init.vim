" Installing plugins
call plug#begin('~/.vim/plugged')

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
Plug	'nathanaelkane/vim-indent-guides'
Plug	'ryanoasis/vim-devicons'
Plug	'ycm-core/YouCompleteMe'

call plug#end()

" NeoVim and Lightline theme
let g:lightline = { 'colorscheme': 'onedark' }
let g:onedark_termcolors=256
set termguicolors
colorscheme onedark

" Make clipboard word interchangable between applications and vim
set clipboard+=unnamedplus

" Enabling syntax highlighting and row numbers
set syntax
set number

" Enabling filetype plugins
filetype plugin on

" Indent guides
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_sart_level = 2

" Open NERDTree when no files specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Make it possible to close NERDTree when it's the only vim screen left
autocmd bufenter * if (winnr("$") == 2 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Keymaps
" Mapping Rainbow to Ctrl+r
map <C-r> :RainbowToggle<CR>

" Mapping NERDTree to Ctrl+n
map <C-n> :NERDTreeToggle<CR>
