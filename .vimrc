"don't try to maintain backward compatability with vi
set nocompatible

let mapleader = "\<SPACE>"

"leave buffers without saving
set hidden

"don't redraw in macros
set lazyredraw

"keep cursor in the middle of the screen when possible
set scrolloff=9999

"use bash aliases so that 'python' = python3
let $BASH_ENV = "~/.bash_aliases"

"don't use h or l repeatedly
nnoremap hh <NOP>
nnoremap ll <NOP>

"easier moving of code blocks
vnoremap < <gv
vnoremap > >gv

"replace word with what's in the 0 register
nnoremap <leader>rep ciw<C-r>0<ESC>
nnoremap <leader>Rep ciW<C-r>0<ESC>
"replace highlighted text with what's in the 0 register
vnoremap <leader>rep c<C-r>0<ESC>

"capitalize word
nnoremap <leader>cap maviwgU`a
nnoremap <leader>Cap maviWgU`a

function! JavaImplementInterface()
    !python $HOME/bin/JavaImplementInterface.py %:p
    -1read $HOME/bin/TEMPJAVINTFILE
    !rm $HOME/bin/TEMPJAVINTFILE
endfunction

"tab stuff
set tabstop=4
set shiftwidth=4
set expandtab

"treat all numerals as decimal, even if prefixed with 0s
set nrformats=

"make splitting more natural
set splitbelow
set splitright

"always show status
set laststatus=2
set statusline+=%F

"highlight search matches as I type
set incsearch
"highlight all matches
"set hlsearch
"remove highlighting easily
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

"manage plugins
execute pathogen#infect()

"theme and syntax highlighting stuff
syntax enable
set background=dark
let g:gruvbox_contrast_dark="hard"
colorscheme gruvbox
hi Normal guibg=NONE ctermbg=NONE
set cursorline

"show line numbers
set number
"set relativenumber

set autoindent

"convenient completion
inoremap <NUL> <C-x><C-i>

filetype plugin indent on
set omnifunc=syntaxcomplete#Complete
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

"only one level of folding
set foldnestmax=1       
"don't show folds initially
set foldlevelstart=20   

"search down into subfolders
"provides tab-completion for all file-related tasks
set path+=**

"display all matching files when we tab complete
set wildmenu

"Create the 'tags' file (install ctags first)
command! MakeTags !ctags -R .

"Search parent directories for tags as well
set tags=./tags,tags;

"Google word shortcut
nnoremap <leader>go :Google<CR>

"Google word under cursor along with name of current language
command! Google let ss = GetSearchString() | execute "!firefox " . ss

function! GetSearchString()
    let pref = ""
    let ext = expand("%:e")
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

"file navigation with netrw
"quick toggle
nnoremap <leader>ee :call ToggleNetrw()<CR>
"disable banner
let g:netrw_banner=0   
"open splits to the right
"let g:netrw_altv=1    
"use tree view
let g:netrw_liststyle=3

function! ToggleNetrw()
    if (&ft == "netrw")
        :bd
    else
        let Lex = 1
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                exe "bd".i
                return 0
            endif
            let i-=1
        endwhile
        :Lexplore
    endif
endfunction

"quick access to buffers
nnoremap <silent> <leader>bo :call CloseAllBuffersButCurrent(0)<CR>
nnoremap <silent> <leader>bo! :call CloseAllBuffersButCurrent(1)<CR>
nnoremap <TAB> :bnext<CR>
nnoremap <S-TAB> :bprev<CR> 

function! CloseAllBuffersButCurrent(force)
    let curr = bufnr("%")
    let i = bufnr("$")
    let cmd = "bd"
    if a:force
        let cmd = cmd."!"
    endif
    while i >= 1
        if curr != i && buflisted(i)
            exe "".cmd.i
        endif
        let i-=1
    endwhile
    exe "ls"
endfunction

"shortcut: <C-SPACE> for tag jumps
nnoremap <NUL> :call TagJump()<CR>

function! TagJump()
    let oneMatch = (len(taglist(expand("<cword>"))) == 1)
    sp
    if oneMatch
        exe "normal! g\<C-]>"
        exe "normal! z\<CR>"
        exe "normal! \<C-w>k"
    else
        exe "ts " . expand("<cword>")
    endif
endfunction

augroup MyAutocmds
    au!

    "run python program
    autocmd FileType python nnoremap <buffer> <leader>run :!python %<CR>

    "reload html page
    autocmd FileType html nnoremap <buffer> <leader>rf :!firefox %<CR>

    "comment quickly with <leader>cm
    autocmd FileType sql vnoremap <buffer> <leader>cm :norm i--<CR>gv
    autocmd FileType sql nnoremap <buffer> <leader>cm ma<ESC>0<ESC>i--<ESC>`a2l
    autocmd FileType python,sh vnoremap <buffer> <leader>cm :norm i#<CR>gv
    autocmd FileType python,sh nnoremap <buffer> <leader>cm ma<ESC>0<ESC>i#<ESC>`al
    autocmd FileType java,javascript,c vnoremap <buffer> <leader>cm :norm i//<CR>gv
    autocmd FileType java,javascript,c nnoremap <buffer> <leader>cm ma<ESC>0<ESC>i//<ESC>`a2l

    "uncomment quickly with <leader>uc
    autocmd FileType sql vnoremap <buffer> <leader>uc :s/^\(\s*\)--/\1/<CR>gv
    autocmd FileType sql nnoremap <buffer> <leader>uc ma:s/^\(\s*\)--/\1/<CR>`a2h
    autocmd FileType java,javascript,c vnoremap <buffer> <leader>uc :s/^\(\s*\)\/\\1///<CR>gv
    autocmd FileType java,javascript,c nnoremap <buffer> <leader>uc ma:s/^\(\s*\)\/\\1///<CR>`a2h
    autocmd FileType python,sh  vnoremap <buffer> <leader>uc :s/^\(\s*\)#/\1/<CR>gv
    autocmd FileType python,sh  nnoremap <buffer> <leader>uc ma:s/^\(\s*\)#/\1/<CR>`ah

    "autocmd FileType sql,java,javascript,c vnoremap <buffer> <leader>uc :norm xx<CR>
    "autocmd FileType sql,java,javascript,c nnoremap <buffer> <leader>uc ma<ESC>0<ESC>xx<ESC>`a
    "autocmd FileType python,sh vnoremap <buffer> <leader>uc :norm x<CR>
    "autocmd FileType python,sh nnoremap <buffer> <leader>uc ma<ESC>0<ESC>x<ESC>`a

    "skeletons
    autocmd FileType c nnoremap <buffer> <leader>sk :-1read $HOME/.vim/.skeleton.c <CR>4j
    autocmd FileType java nnoremap <buffer> <leader>sk :-1read $HOME/.vim/.skeleton.java 
         \<CR>ggf<d$"%pF.d$jji<TAB><SPACE><ESC>
    autocmd FileType html nnoremap <buffer> <leader>sk :-1read $HOME/.vim/.skeleton.html <CR>

    "c include statement
    autocmd FileType c nnoremap <buffer> <leader>inc ma gg :-1read $HOME/.vim/.cinclude.c <CR> f>i

    "c for-loop snippet
    autocmd FileType c nnoremap <buffer> <leader>for :-1read $HOME/.vim/.cloop.c <CR>

    "html complete tag
    autocmd FileType html inoremap <buffer> <c-f> <ESC>maF<w<ESC>yiw`aa</><ESC>hpF<i

    "html align tags vertically and position cursor on line in between
    autocmd FileType html inoremap <buffer> <c-n> <ESC>F<<ESC>f>li<CR><SPACE><SPACE><ESC>f<i<CR><ESC>kI

    "java add interface skeletons
    autocmd FileType java nnoremap <buffer> <leader>int :exe JavaImplementInterface() <CR>

    "insert sql foreign key snippet
    autocmd FileType sql nnoremap <buffer> <leader>fk :-1read $HOME/.vim/.sqlforeignkey <CR> 3>>0 magg0 f(byiw`a/\|\|\|<CR>hpndiwnciw

    "remove preview window after auto-completion
    autocmd CompleteDone * pclose

    "remind me not to go over 79 chars in a line
    autocmd FileType c,python,java,javascript,scheme,sh,sql,html,css match ErrorMsg "\%>80v.\+"

    "fold by indentation for python
    autocmd FileType python setlocal foldmethod=indent

augroup END
