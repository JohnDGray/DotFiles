set nocompatible

set tabstop=4
"set softtabstop=4
set shiftwidth=4
set expandtab
set colorcolumn=80

"show status
set laststatus=2
set statusline+=%F

nnoremap <Tab> :b 

execute pathogen#infect()

syntax enable
set background=dark

"let g:solarized_termcolors=256
"colorscheme solarized

let g:gruvbox_contrast_dark="hard"
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
set foldlevelstart=20

set path+=**
set wildmenu

command! MakeTags !ctags -R .

function! GetSearchString()
    let pref = ""
    let ext = expand('%:e')
    if ext == "py"
        let pref = "python+"
    elseif ext == "c"
        let pref = "c+"
    elseif ext == "sh"
        let pref = "bash+"
    elseif ext == "java"
        let pref = "java+"
    elseif ext == "js"
        let pref = "javascript+"
    elseif ext == "scm"
        let pref = "scheme+language+"
    endif
    let pref = "https://www.google.com/search?q=" . pref . "<cword>"
    return pref
endfunction 

command! Google let ss = GetSearchString() | execute '!firefox ' . ss

let g:netrw_banner=0        "disable banner
let g:netrw_altv=1          "open splits to the right
let g:netrw_liststyle=3     "tree view
