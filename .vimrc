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
set tabstop=4
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

"capitalize word
nnoremap <leader>cp maviwgU`a
nnoremap <leader>Cp maviWgU`a

"easier window navigation
nnoremap <leader>w <C-w>

"'make' shortcut
nnoremap <silent> <F5> :silent make!<CR> <C-l>

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
        if !word
            normal! b
            let word = expand("<cword>")
        endif
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
        normal! `a
        if !g:tag_window_displayed
            echo "Could not display tag"
        endif
    endif
endfunction

"for use with language-aware definition jump tools
function! ToggleDefWindow(func)
    if g:tag_window_displayed
        let g:tag_window_displayed=0
        if winnr('$') > 1
            wincmd p
            q
        endif
    else
        let g:tag_window_displayed=1
        spl
        exe a:func
        wincmd p
    endif
endfunction

"tag completion
inoremap <expr> <NUL> CompleteString()
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

function! CompleteString()
    if pumvisible()
        return "\<C-n>"
    else
        return "\<C-x>\<C-o>\<C-r>=CompleteOpened()\<CR>"
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

function! ToggleQuickFix()
    if !empty(getqflist())
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

set noshowmode
"---------------------------------------------
"-------------------Section-------------------
"-------------------Plugins-------------------
"---------------------------------------------
"ultisnips triggers
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

let g:jedi#auto_vim_configuration = 0
let g:jedi#popup_on_dot = 0
let g:jedi#show_call_signatures = "2"
let g:jedi#smart_auto_mappings = 0
let g:jedi#goto_command = ""
let g:jedi#completions_command = ""
let g:jedi#rename_command = ""

"---------------------------------------------
"-------------------Section-------------------
"-------------------Autocmds------------------
"---------------------------------------------
augroup MyAutocmds
    au!

    "remove preview window after auto-completion
    autocmd CompleteDone * pclose

    "toggle quickfix window when quickfix list is changed
    autocmd QuickFixCmdPost * silent call ToggleQuickFix()

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
    autocmd FileType html inoremap <buffer> <C-f> </<C-x><C-o>

    "----------------------
    "------javascript------
    "----------------------
    "run program
    autocmd FileType javascript nnoremap <buffer> <leader>rn :!clear <CR><CR>:!nodejs %<CR>
    "run program and pipe to less
    autocmd FileType javascript nnoremap <buffer> <leader>Rn :!clear <CR><CR>:!nodejs % \| less<CR>
    "tern go to definition
    autocmd FileType javascript nnoremap <silent> <buffer> <leader>d :call ToggleDefWindow("TernDef")<CR>
    "tern documentation
    autocmd FileType javascript nnoremap <silent> <buffer> K :TernDoc<CR>

    "----------------------
    "--------python--------
    "----------------------
    "run program
    autocmd FileType python nnoremap <buffer> <leader>rn :!clear <CR><CR>:!python3 %<CR>
    "run program and pipe output to less
    autocmd FileType python nnoremap <buffer> <leader>Rn :!clear <CR><CR>:!python3 % \| less<CR>
    "fold by indentation
    autocmd FileType python setlocal foldmethod=indent
    "jedi go to definition
    autocmd FileType python nnoremap <silent> <buffer> <leader>d :call ToggleDefWindow("call jedi#goto()")<CR>

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
    "c
    "skeleton
    autocmd BufNewFile *.c 0r $HOME/.vim/.skeleton.c
augroup END
