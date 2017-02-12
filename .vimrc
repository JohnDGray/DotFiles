"don't try to maintain backward compatability with vi
set nocompatible

"tab stuff
set tabstop=4
set shiftwidth=4
set expandtab
"remind me not to go over 80 chars in a line
set colorcolumn=80

"make splitting more natural
set splitbelow
set splitright

"always show status
set laststatus=2
set statusline+=%F

"don't require save to navigate away from file in buffer
"set hidden

"manage plugins
execute pathogen#infect()

"theme stuff
syntax enable
set background=dark
let g:gruvbox_contrast_dark="hard"
colorscheme gruvbox

"show line numbers
set number

set autoindent

inoremap <NUL> <C-x><C-i>

filetype plugin on
"if v:version >= 700
"    let OmniCpp_GlobalScopeSearch   = 1
"    let OmniCpp_DisplayMode         = 1
"    let OmniCpp_ShowPrototypeInAbbr = 1 "show prototype in pop-up
"    let OmniCpp_ShowAccess          = 1 "show access in pop-up
"    let OmniCpp_SelectFirstItem     = 1 "select first item in pop-up
"    set completeopt=menuone,menu,longest
"endif

if has("autocmd")
	filetype plugin indent on
endif

"fold using syntax normally
set foldmethod=syntax
"but fold by indentation for python
autocmd FileType python setlocal foldmethod=indent

"only one level of folding
set foldnestmax=1       
"don't show folds initially
set foldlevelstart=20   

set path+=**
set wildmenu

"Generate tags for current directory and child directories
command! MakeTags !ctags -R .

"Search parent directories for tags as well
set tags=./tags,tags;

"Google word under cursor along with name of current language
command! Google let ss = GetSearchString() | execute '!firefox ' . ss

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

"file navigation
"disable banner
let g:netrw_banner=0   
"open splits to the right
let g:netrw_altv=1    
"use tree view
let g:netrw_liststyle=3 

"quick access to files in buffer: just hammer tab
nnoremap <Tab> :b 

"shortcut tag jumps
nnoremap <NUL> :sp<CR>g<C-]>
