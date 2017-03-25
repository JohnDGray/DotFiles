"don't try to maintain backward compatability with vi
set nocompatible

let $BASH_ENV = "~/.bash_aliases"

nnoremap hh <NOP>
nnoremap ll <NOP>

nnoremap ,r wbhmalcw<C-r>0<ESC>`al

"bring next line up and merge with current line
nnoremap ,l maj0i<SPACE><ESC>0dwkA<SPACE><DEL><ESC>`a

"skeletons
autocmd FileType c nnoremap ,sk :-1read $HOME/.vim/.skeleton.c <CR>4j
autocmd FileType java nnoremap ,sk :-1read $HOME/.vim/.skeleton.java 
            \<CR>ggf<d$"%pF.d$jji<TAB><SPACE><ESC>
autocmd FileType html nnoremap ,sk :-1read $HOME/.vim/.skeleton.html <CR>

"c include statemen
autocmd FileType c nnoremap ,inc ma gg :-1read $HOME/.vim/.cinclude.c <CR> f>i

"c for-loop snippet
autocmd FileType c nnoremap ,for :-1read $HOME/.vim/.cloop.c <CR>

"html complete tag
autocmd FileType html inoremap <c-f> ><ESC>F<yi<f>a</<ESC>pa><ESC>F<i

"html align tags vertically and position cursor on line in between
autocmd FileType html inoremap <c-n> <CR><SPACE><CR><ESC>wki<TAB>

"java add interface skeletons
autocmd FileType java nnoremap ,int :exe JavaImplementInterface() <CR>

function! JavaImplementInterface()
    !python $HOME/bin/JavaImplementInterface.py %:p
    -1read $HOME/bin/TEMPJAVINTFILE
    !rm $HOME/bin/TEMPJAVINTFILE
endfunction

"tab stuff
set tabstop=4
set shiftwidth=4
set expandtab
"remind me not to go over 79 chars in a line
"set colorcolumn=80
match ErrorMsg '\%>80v.\+'

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

hi Normal guibg=NONE ctermbg=NONE

"show line numbers
set number
set relativenumber

set autoindent

inoremap <NUL> <C-x><C-i>

filetype plugin on
set omnifunc=syntaxcomplete#Complete
autocmd CompleteDone * pclose
set completeopt=longest,menuone
function! Auto_complete_string()
    if pumvisible()
        return "\<C-n>"
    else
        return "\<C-x>\<C-o>\<C-r>=Auto_complete_opened()\<CR>"
    end
endfunction

function! Auto_complete_opened()
    if pumvisible()
        return "\<Down>"
    else
        return "X\<bs>\<C-n>"
    end
endfunction

inoremap <expr> <Nul> Auto_complete_string()

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
    elseif ext == "html"
        let pref = "MDN+\\<"
    endif
    let pref = "https://www.google.com/search?q=" . pref . "<cword>"
    if ext == "html"
        let pref = pref . "\\>"
    endif
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
nnoremap <Tab> :b!

"shortcut tag jumps
nnoremap <NUL> :call TagJump()<CR>

function! TagJump()
    let oneMatch = (len(taglist(expand('<cword>'))) == 1)
    sp
    if oneMatch
        exe "normal! g\<C-]>"
        exe "normal! z\<CR>"
        exe "normal! \<C-w>k"
    else
        exe "ts " . expand('<cword>')
    endif
endfunction
