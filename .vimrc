set nocompatible

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set colorcolumn=80 

execute pathogen#infect()

syntax enable
set background=dark

"let g:solarized_termcolors=256
"colorscheme solarized

colorscheme gruvbox

"colorscheme apprentice

set number

set autoindent

filetype plugin on

if has("autocmd")
	filetype plugin indent on
endif

set foldmethod=syntax
set foldnestmax=1

set path+=**
set wildmenu

command! MakeTags !ctags -R .

let g:netrw_banner=0        "disable banner
let g:netrw_altv=1          "open splits to the right
let g:netrw_liststyle=3     "tree view
