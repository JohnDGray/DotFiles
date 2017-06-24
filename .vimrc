"---------------------------------------------
"-------------------Section-------------------
"-------------------Settings------------------
"---------------------------------------------

"manage plugins
execute pathogen#infect()

"leader
let mapleader = "\<SPACE>"

"color scheme and syntax highlighting stuff
syntax enable
set background=dark
let g:gruvbox_contrast_dark="hard"
colorscheme gruvbox
hi Normal ctermbg=NONE

"leave buffers without saving
set hidden

"keep cursor in the middle of the screen when possible
set scrolloff=9999

"use bash aliases so that 'python' = python3
let $BASH_ENV = "~/.bash_aliases"

"tab stuff
set softtabstop=4
set shiftwidth=4
set expandtab

"indent at same level as last line
set autoindent

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

"show line numbers
set number

"use filetype information
filetype plugin indent on

"completion
set completeopt=longest,menuone

"fold using syntax (except for python: see below)
set foldmethod=indent
"only one level of folding
set foldnestmax=1       
"don't show folds initially
set foldlevelstart=20   

"recursive file searches
set path+=**

"display all matching files when we tab complete
set wildmenu

"search parent directories for tags as well
set tags=./tags,tags;

"netrw
"disable banner
let g:netrw_banner=0   
"use tree view
let g:netrw_liststyle=3

"---------------------------------------------
"-------------------Section-------------------
"------------------Shortcuts------------------
"---------------------------------------------

"replace word with whatever is in the 0 register (last yank even after delete)
nnoremap <leader>rp ciw<C-r>0<ESC>
nnoremap <leader>Rp ciW<C-r>0<ESC>

"easier window navigation
nnoremap <leader>w <C-w>

"write and make
nnoremap <silent> <F5> :w \| silent make!<CR>

"create/update tags
command! MakeTags !ctags -Rnu --exclude=.git .

"tag window
nnoremap <silent> <F10> :call ToggleTagWindow()<CR>
inoremap <silent> <expr> <F10> "\<ESC>:call ToggleTagWindow()\<CR>a"

let g:tag_window_displayed=0

function! ToggleTagWindow()
    if g:tag_window_displayed
        let g:tag_window_displayed=0
        if winnr('$') > 1
            wincmd p
            q
        endif
    else
        normal! ma
        let word = expand("<cword>")
        if word == ""
            normal! b
            let word = expand("<cword>")
        endif
        if word != ""
            while 1
                try 
                    exe "stj " . word
                    let g:tag_window_displayed=1
                    wincmd p
                    break   
                catch
                    if col('.') == 1
                        break
                    endif
                    normal! b
                    let word = expand("<cword>")
                endtry
            endwhile
        endif
        normal! `a
        if !g:tag_window_displayed
            echo "Could not display tag"
        endif
    endif
endfunction

"tag completion
inoremap <expr> <NUL> CompleteString()
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> ) g:tag_window_displayed ? ")\<ESC>:call ToggleTagWindow()\<CR>a" : ")"

function! CompleteString()
    if pumvisible()
        return "\<C-n>"
    else
        return "\<C-x>\<C-]>"
    endif
endfunction

function! CompleteOpened()
    if pumvisible()
        return "\<Down>"
    endif
    return ""
endfunction

"show documentation
nnoremap <leader>K :call GetDocs()<CR>

function! GetDocs()
    let urls = {"python": "https://docs.python.org/3/search.html?q=", "javascript": "https://developer.mozilla.org/en-US/search?q=", "html": "https://developer.mozilla.org/en-US/search?q=", "css": "https://developer.mozilla.org/en-US/search?q=",}
    if has_key(urls, &ft)
        let ss = urls[&ft]
    else
        let ss = "https://www.google.com/search?q=" . &ft . "+"
    endif
    let ss = ss . expand("<cword>")

    "Open a new firefox instance (create a second profile and use it instead of 'alt'):
    exe 'silent !firefox -P alt ' . '"' . ss . '"' . ' &'

    ""Use an existing firefox instance:
    "exe 'silent !firefox ' . '"' . ss . '"' . ' &'
endfunction

"netrw quick toggle
nnoremap <leader>ee :call ToggleNetrw()<CR>

let g:NetrwIsOpen=0

function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout ".i
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        :Lexplore
    endif
endfunction

"delete buffer without closing window
nnoremap <leader>bd :b#\|bd #<CR>
"close all open buffers except current buffer
nnoremap <silent> <leader>bo :call CloseAllBuffersButCurrent()<CR>

function! CloseAllBuffersButCurrent()
    let curr = bufnr("%")
    let i = bufnr("$")
    let cmd = "bd"
    while i >= 1
        if curr != i && buflisted(i)
            exe "".cmd.i
        endif
        let i-=1
    endwhile
    exe "ls"
endfunction

"commenting
nnoremap <silent> <leader>cc :<C-U>call AddComment(0)<CR>
vnoremap <silent> <leader>cc :<C-U>call AddComment(1)<CR>
nnoremap <silent> <leader>cu :<C-U>call RemoveComment(0)<CR>
vnoremap <silent> <leader>cu :<C-U>call RemoveComment(1)<CR>

function! GetComment()
    let comments = {"vim": "\"", "python": "# ", "sql": "--", "javascript": "//", "java": "//", "c": "//",}
    if has_key(comments, &ft)
        return comments[&ft]
    else
        return "#"
    endif
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
            let command = command . ",+" . string(min([(vcount - 1), (line('$') - line('.'))]))
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
            let command = command . ",+" . string(min([(vcount - 1), (line('$') - line('.'))]))
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

function! RefreshQuickFix()
    if !empty(getqflist())
        copen
        wincmd p
    else
        cclose
    endif
    redraw!
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

"ultisnips triggers
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

"---------------------------------------------
"-------------------Section-------------------
"-------------------Autocmds------------------
"---------------------------------------------

augroup MyAutocmds
    au!

    "remove preview window after auto-completion
    autocmd CompleteDone * pclose

    "toggle quickfix window when quickfix list is changed
    autocmd QuickFixCmdPost * silent call RefreshQuickFix()

    autocmd BufWritePost * silent call RelintIfAlreadyLinting()

    "Update tags on write
    autocmd BufWritePost  * silent exe "!UpdateTags.sh ."

    "no autocomment on next line after comment
    autocmd FileType * set formatoptions-=c formatoptions-=r formatoptions-=o 

    "resize windows when vim is resized
    autocmd VimResized * wincmd =

    "----------------------
    "---------html---------
    "----------------------
    "skeleton
    autocmd BufNewFile *.html 0r $HOME/.vim/.skeleton.html
    "complete tag
    autocmd FileType html inoremap <buffer> <NUL> </<C-x><C-o><Down><CR>
    autocmd FileType html inoremap <buffer> <C-f> <ESC>/><CR>a
    autocmd FileType html inoremap <buffer> <C-b> <ESC>?<<CR>?><CR>a

    "----------------------
    "------javascript------
    "----------------------
    "run program
    autocmd FileType javascript nnoremap <buffer> <leader>rn :!clear <CR><CR>:!nodejs %<CR>
    "run program and pipe to less
    autocmd FileType javascript nnoremap <buffer> <leader>Rn :!clear <CR><CR>:!nodejs % \| less<CR>

    "----------------------
    "--------python--------
    "----------------------
    "run program
    autocmd FileType python nnoremap <buffer> <leader>rn :!clear <CR><CR>:!python3 %<CR>
    "run program and pipe output to less
    autocmd FileType python nnoremap <buffer> <leader>Rn :!clear <CR><CR>:!python3 % \| less<CR>
    "fold by indentation
    autocmd FileType python setlocal foldmethod=indent

    "----------------------
    "---------sql----------
    "----------------------
    "try script
    "autocmd FileType sql nnoremap <buffer> <leader>t :!psql <<<dbname>>> -f %<CR>
    "run script
    "autocmd FileType sql nnoremap <buffer> <leader>rn :!RunQuery.sh dbname % file.csv

    "----------------------
    "-----------c----------
    "----------------------
    "make sure headers are classified as c files and not cpp files
    autocmd! BufRead,BufNewFile *.h set filetype=c
    "skeleton
    autocmd BufNewFile *.c 0r $HOME/.vim/.skeleton.c
    "compile
    autocmd FileType c nnoremap <buffer> <leader>mk :w<CR>:!clear<CR><CR>:!gcc %<CR>
    "run program
    autocmd FileType c nnoremap <buffer> <leader>rn :!clear<CR><CR>:!valgrind ./a.out<CR>
    "run program and pipe to less
    autocmd FileType c nnoremap <buffer> <leader>Rn :!clear<CR><CR>:!valgrind ./a.out \| less<CR>
augroup END
