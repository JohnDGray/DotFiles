let mapleader = "\<SPACE>"

"leave buffers without saving
set hidden

"keep cursor in the middle of the screen when possible
set scrolloff=9999

"use bash aliases so that 'python' = python3
let $BASH_ENV = "~/.bash_aliases"

nnoremap <leader>3 :call ToggleRelativeNumber()<CR>

function! ToggleRelativeNumber()
    if &relativenumber
        set norelativenumber
    else
        set relativenumber
    endif
endfunction

"easier (un)indenting of code blocks
vnoremap < <gv
vnoremap > >gv

"easier window navigation
nnoremap <leader>wp <C-w>p
nnoremap <leader>wh <C-w>h
nnoremap <leader>wj <C-w>j
nnoremap <leader>wk <C-w>k
nnoremap <leader>wl <C-w>l

"replace word with whatever is in the 0 register
nnoremap <leader>rep ciw<C-r>0<ESC>
nnoremap <leader>Rep ciW<C-r>0<ESC>
"replace highlighted text with whatever is in the 0 register
vnoremap <leader>rep c<C-r>0<ESC>

"tab stuff
set tabstop=4
set shiftwidth=4
set expandtab

"capitalize last word
nnoremap <leader>cap maviwgU`a
nnoremap <leader>Cap maviWgU`a

"treat all numerals as decimal, even if prefixed with 0s
set nrformats=

"make splitting more natural
set splitbelow
set splitright

"always show status
set laststatus=2
set statusline+=%n\ %F
set statusline+=%=
"set statusline+=%{getcwd()}

"set title titlestring=%{getcwd()}

"highlight search matches as I type
set incsearch
"highlight all matches
"set hlsearch
"remove highlighting easily
"nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

"manage plugins
execute pathogen#infect()

"theme and syntax highlighting stuff
syntax enable
set background=dark
let g:gruvbox_contrast_dark="hard"
colorscheme gruvbox
hi Normal ctermbg=NONE
"set cursorline

"show line numbers
set number
"set relativenumber

"indent at same level as last line
set autoindent

filetype plugin indent on

"Completion
set completeopt=longest,menuone
inoremap <expr> <NUL> Auto_complete_string()
inoremap <expr> <CR> Completion_lookup()
inoremap <expr> \|\|\| "\<ESC>:on\<CR>a"

function! Auto_complete_string()
    if pumvisible()
        return "\<Down>"
    else
        return "\<C-x>\<C-]>\<C-r>=Auto_complete_opened()\<CR>"
    end
endfunction

function! Auto_complete_opened()
    if pumvisible()
        return "\<Down>"
    end
    return ""
endfunction

function! Completion_lookup()
    if pumvisible()
        return "\<CR>\<ESC>:call TagJump()\<CR>a"
    else
        return "\<CR>"
    endif
endfunction

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

"Update tags
command! MakeTags !ctags -Rnu --exclude=.git .

"Search parent directories for tags as well
set tags=./tags,tags;

"Google word shortcut
nnoremap K :call GetDocs()<CR>

function! GetDocs()
    let ss = "https://www.google.com/search?q="
    if (&ft == "python")
        let ss = "https://docs.python.org/3/search.html?q="
    elseif (&ft == "javascript" || &ft == "html" || &ft == "css")
        let ss = "https://developer.mozilla.org/en-US/search?q="
    else
        let ss = ss . GetLanguage()
    endif
    let ss = ss . expand("<cword>")
    let ss = substitute(ss, "(", "\\\\(", "g") 
    let ss = substitute(ss, ")", "\\\\)", "g") 
    let ss = substitute(ss, "<", "\\\\<", "g") 
    let ss = substitute(ss, ">", "\\\\>", "g") 
    let ss = substitute(ss, "|", "\\\\|", "g") 
    let ss = substitute(ss, "!", "\\\\!", "g") 
    let ss = substitute(ss, "&", "\\\\&", "g") 
    let ss = substitute(ss, ";", "\\\\;", "g") 
    exe "silent !firefox -P alt " . ss . " &"
endfunction

function! GetLanguage()
    let result = ""
    if (&ft == "sh")
        let result = "bash"
    else
        let result = "" . &ft
    endif
    if result != ""
        let result = result . "+"
    endif
    return result
endfunction 

"file navigation with netrw
"quick toggle
nnoremap <leader>ee :call ToggleNetrw()<CR>
"disable banner
let g:netrw_banner=0   
"use tree view
let g:netrw_liststyle=3

function! ToggleNetrw()
    let lex = 1
    let i = bufnr("$")
    while (i >= 1)
        if (getbufvar(i, "&filetype") == "netrw")
            silent exe "bwipeout ".i
            let lex = 0
        endif
        let i-=1
    endwhile
    if lex
        :Lexplore
    endif
endfunction

"quick buffer control
nnoremap <BS> :b#<CR>
nnoremap <leader>bd :b#\|bd #<CR>
nnoremap <silent> <leader>bo :call CloseAllBuffersButCurrent(0)<CR>

"quickfix shortcuts
nnoremap <leader>cf :cfirst<CR>
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprevious<CR>

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

"commenting
nnoremap <silent> <leader>cm :<C-U>call AddComment(0)<CR>
vnoremap <silent> <leader>cm :<C-U>call AddComment(1)<CR>
nnoremap <silent> <leader>uc :<C-U>call RemoveComment(0)<CR>
vnoremap <silent> <leader>uc :<C-U>call RemoveComment(1)<CR>

function! GetComment()
    let comment = "#"
    if &ft == "sql"
        let comment = "--"
    elseif &ft == "vim"
        let comment = "\""
    elseif index(["java", "javascript", "c"], &ft) > -1
        let comment = "//"
    endif
    return comment
endfunction

function! AddComment(from_visual)
    let vcount = v:count
    if !a:from_visual
        normal! ma
    endif
    let command = ":"
    if a:from_visual
        let command = command . "'<,'>"
    else
        let command = command . "."
        if vcount && vcount > 1
            let command = command . ",+" . string(vcount - 1)
        endif
    endif
    let comment = GetComment()
    let command = command . "norm i" . comment
    exe command
    if a:from_visual
        normal! gv
    else
        normal! `a
    endif
    exe "normal! " . string(len(comment)) . "l"
endfunction

function! RemoveComment(from_visual)
    let vcount = v:count
    if !a:from_visual
        normal! ma
    endif
    let command = ":"
    if a:from_visual
        let command = command . "'<,'>"
    else
        let command = command . "."
        if vcount && vcount > 1
            let command = command . ",+" . string(vcount - 1)
        endif
    endif
    let comment = GetComment()
    let cs = len(comment)
    let comment = substitute(comment, "/", "\\\\/", "g")
    let pos = col('.')
    let ll = len(getline('.'))
    let offset = min([(ll-pos), cs])
    let command = command . "s/^\\(\\s*\\)" . comment . "/\\1/"
    silent exe command
    if a:from_visual
       normal! gv
    else
        normal! `a
    endif
    if offset > 0
        exe "normal! " . string(offset) . "h"
    endif
endfunction

nnoremap <leader>d :call TagJump()<CR>

function! TagJump()
    try
        let word = expand("<cword>")
        exe "stj " . word
    catch
        :echo "Could not display definition"
        return
    endtry
    wincmd p
endfunction

"---------------------------------------------
"-------------------Section-------------------
"-------------------Plugins-------------------
"---------------------------------------------
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_wq = 0
let g:syntastic_enable_signs = 0
let g:syntastic_enable_balloons = 0
let g:syntastic_enable_highlighting = 0
let g:syntastic_python_checkers = ['flake8']

"set ultisnips triggers
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

"---------------------------------------------
"-------------------Section-------------------
"-------------------Autocmds------------------
"---------------------------------------------
augroup MyAutocmds
    au!

    "Update tags on write
    autocmd BufWritePost  * silent exe "!UpdateTags.sh ."

    "no autocomment on next line after comment
    autocmd FileType * set formatoptions-=c formatoptions-=r formatoptions-=o 

    "resize windows when vim is resized
    autocmd VimResized * wincmd =

    "-------------
    "---au-html---
    "-------------
    "skeleton
    autocmd BufNewFile *.html 0r $HOME/.vim/.skeleton.html
    "complete tag
    autocmd FileType html nnoremap <buffer> <leader>f a</<C-x><C-o><ESC>F<i
    "align tags vertically and position cursor on line in between
    "autocmd FileType html nnoremap <buffer> <leader><CR> f<<ESC>i<CR><CR><ESC>k<ESC>I<TAB>
    autocmd FileType html nnoremap <buffer> <leader><CR> f<<ESC>i<CR><CR><ESC>k<ESC>I<TAB>
    "jump past next tag
    autocmd FileType html nnoremap <buffer> <leader><leader> /><CR>l
    "jump past previous tag
    autocmd FileType html nnoremap <buffer> <NUL><NUL> ?<<CR>?><CR>l

    "-------------------
    "---au-javascript---
    "-------------------
    "run program
    autocmd FileType javascript nnoremap <buffer> <leader>run :!clear <CR><CR>:!nodejs %<CR>
    "run program and pipe to less
    autocmd FileType javascript nnoremap <buffer> <leader>lrun :!clear <CR><CR>:!nodejs % \| less<CR>

    "---------------
    "---au-python---
    "---------------
    "run program
    autocmd FileType python nnoremap <buffer> <leader>run :!clear <CR><CR>:!python %<CR>
    "run program and pipe output to less
    autocmd FileType python nnoremap <buffer> <leader>lrun :!clear <CR><CR>:!python % \| less<CR>
    "fold by indentation
    autocmd FileType python setlocal foldmethod=indent

    "------------
    "---au-sql---
    "------------
    "try script
    "autocmd FileType sql nnoremap <buffer> <leader>try :!psql <<<dbname>>> -f %<CR>
    "run script
    autocmd FileType sql nnoremap <buffer> <leader>run :!RunQuery.sh dbname % file.csv

    "c
    "skeleton
    autocmd BufNewFile *.c 0r $HOME/.vim/.skeleton.c

    "remove preview window after auto-completion
    autocmd CompleteDone * pclose


augroup END
