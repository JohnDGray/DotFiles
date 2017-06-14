"------------------------------
"-----------Section------------
"-----------General------------
"------------------------------
"manage plugins
execute pathogen#infect()

"leader
let mapleader = "\<SPACE>"

"leave buffers without saving
set hidden

"keep cursor in the middle of the screen when possible
set scrolloff=9999

"use bash aliases so that 'python' = python3
let $BASH_ENV = "~/.bash_aliases"

"replace word with whatever is in the 0 register
nnoremap <leader>rep ciw<C-r>0<ESC>
nnoremap <leader>Rep ciW<C-r>0<ESC>

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
set statusline+=%{getcwd()}

"highlight search matches as I type
set incsearch

"color scheme and syntax highlighting stuff
syntax enable
set background=dark
let g:gruvbox_contrast_dark="hard"
colorscheme gruvbox
hi Normal ctermbg=NONE

"show line numbers
set number
"set relativenumber

"indent at same level as last line
set autoindent

filetype plugin indent on

"Completion
set completeopt=longest,menuone
inoremap <expr> <NUL> Auto_complete_string()
nnoremap <silent> <F10> :call Toggle_Def()<CR>
inoremap <silent> <expr> <F10> "\<ESC>:call Toggle_Def()\<CR>a"

let g:definition_displayed=0

function! Toggle_Def()
    if g:definition_displayed
        let g:definition_displayed=0
        if winnr('$') > 1
            wincmd p
            q
        endif
    else
        normal! ma
        let word = expand("<cword>")
        if !word
            normal! b
            let word = expand("<cword>")
        endif
        while col('.') > 1
            try 
                exe "stj " . word
                let g:definition_displayed=1
                wincmd p
                break   
            catch
                normal! b
                let word = expand("<cword>")
            endtry
        endwhile
        if !g:definition_displayed
            try 
                exe "stj " . word
                let g:definition_displayed=1
                wincmd p
            catch
            endtry
        endif
        normal! `a
        if !g:definition_displayed
            echo "Could not display definition"
        endif
    endif
endfunction
        

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

"fold using syntax (except for python: see below)
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

"Create/Update tags
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

"delete buffer without closing window
nnoremap <leader>bd :b#\|bd #<CR>
"close all open buffers except current buffer
nnoremap <silent> <leader>bo :call CloseAllBuffersButCurrent(0)<CR>

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

"make/linting shortcut
nnoremap <silent> <F5> :silent make!<CR> <C-l>

function! OpenQuickfix()
    if ! empty(getqflist())
        copen
        redraw!
        wincmd p
    else
        cclose
    endif
endfunction

function! QuickFixIsOpen()
    let i = winnr("$")
    while i >= 0
        if getbufvar(winbufnr(i), '&buftype') == 'quickfix'
            return 1
        endif
        let i -= 1
    endwhile
    return 0
endfunction

function! RelintIfAlreadyLinting()
    if QuickFixIsOpen()
        silent make!
    endif
endfunction

"---------------------------------------------
"-------------------Section-------------------
"-------------------Plugins-------------------
"---------------------------------------------
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

    autocmd QuickFixCmdPost * silent call OpenQuickfix()

    autocmd BufWritePost * silent call RelintIfAlreadyLinting()

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
    autocmd FileType html inoremap <buffer> <C-f> </<C-x><C-o>

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
