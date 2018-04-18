"---------------------------------------------
"-------------------Section-------------------
"-------------------Settings------------------
"---------------------------------------------

set backspace=indent,eol,start

set noerrorbells visualbell t_vb=

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

"use filetype information
filetype plugin indent on

"leave buffers without saving
set hidden

"keep cursor in the middle of the screen when possible
set scrolloff=9999

"use bash aliases so that 'python' = python3
"let $BASH_ENV = "~/.bash_aliases"
let $BASH_ENV = "~/.bashrc"

"tab stuff
set softtabstop=2
set shiftwidth=2
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
"include buffer number and file name in status line
set statusline+=%n\ %F
set statusline+=%=
"include working directoryin status line
set statusline+=%{getcwd()}

"highlighting
"highlight search matches as I type
set incsearch
"highlight all matches
set hlsearch
"turn off hlsearch when redrawing
nnoremap <C-l> :nohlsearch<CR><C-l>

"show line numbers
set number

"use completion menu even for just one match; insert only the longest common match among choices
set completeopt=longest,menuone

"fold using indentation
set foldmethod=indent
"only one level of folding
set foldnestmax=1       
"don't show folds initially
set foldlevelstart=20   

"recursive file searches
set path+=**

"display all matching files when I tab complete
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

"always use very magic
nnoremap / /\v
nnoremap s/ s/\v

"delete blank lines
nnoremap <leader>db :%g/\v^\s*$/d<CR>
vnoremap <leader>db :g/\v^\s*$/d<CR>

"trim lines at front and end
nnoremap <leader>tr :%s/\v(^\s+)\|(\s+$)//g<CR>
vnoremap <leader>tr :s/\v(^\s+)\|(\s+$)//g<CR>

"trim lines at end
nnoremap <leader>te :%s/\v(\s+$)//<CR>
vnoremap <leader>te :s/\v(\s+$)//<CR>

"create/update tags
command! MakeTags !ctags -Rnu --exclude=.git .

"write and make
nnoremap <silent> <F5> :w \| silent make!<CR>

"write to a read-only file
command! WriteSudo w !sudo tee > /dev/null %

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

"omni completion
inoremap <expr> <NUL> CompleteString()
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <C-n> pumvisible() ? "\<C-n>" : "\<C-n>\<C-n>"

function! CompleteString()
    if pumvisible()
        return "\<C-n>"
    else
        return "\<C-x>\<C-o>"
    endif
endfunction

"show documentation
nnoremap <silent> <leader>k :call GetDocs()<CR>

function! GetDocs()
    let urls = {"python": "https://docs.python.org/3/search.html?q=", "javascript": "https://developer.mozilla.org/en-US/search?q=", "html": "https://developer.mozilla.org/en-US/search?q=", "css": "https://developer.mozilla.org/en-US/search?q=",}
    if has_key(urls, &ft)
        let ss = urls[&ft]
    else
        let ss = "https://www.google.com/search?q=" . &ft . "+"
    endif
    let ss = ss . expand("<cword>")

    "Open a new firefox instance (you should create a second profile and use it instead of 'alt'):
    exe 'silent !firefox -P alt ' . '"' . ss . '"' . ' &'

    ""Use an existing firefox instance:
    "exe 'silent !firefox ' . '"' . ss . '"' . ' &'
endfunction

"netrw quick toggle
nnoremap <silent> <leader>ee :call ToggleNetrw()<CR>

let g:NetrwIsOpen=0

function! ToggleNetrw()
    if g:NetrwIsOpen
        let i = bufnr("$")
        while (i >= 1)
            if (getbufvar(i, "&filetype") == "netrw")
                silent exe "bwipeout " . i
            endif
            let i-=1
        endwhile
        let g:NetrwIsOpen=0
    else
        let g:NetrwIsOpen=1
        silent Lexplore
    endif
endfunction

"delete buffer without closing window
nnoremap <silent> <leader>bd :b#\|bd #<CR>
"close all open buffers except current buffer
nnoremap <silent> <leader>bo :call CloseAllBuffersButCurrent()<CR>

function! CloseAllBuffersButCurrent()
    let curr = bufnr("%")
    let i = bufnr("$")
    while i >= 1
        if i != curr && buflisted(i)
            exe "bd " . i
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

function! AddTwoPartComment(from_visual, open_comment, end_comment)
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
    let command = command . "norm I" . a:open_comment . "\<ESC>A" . a:end_comment
    exe command
    if a:from_visual
        normal! gv
    else
        normal! `a
    endif
    exe "normal! " . string(len(a:open_comment)) . "l"
endfunction

function! RemoveTwoPartComment(from_visual, open_comment, end_comment)
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
    let cs = len(a:open_comment)
    let open_com = substitute(a:open_comment, "/", "\\\\/", "g")
    let open_com = substitute(open_com, "*", "\\\\*", "g")
    let end_com = substitute(a:end_comment, "/", "\\\\/", "g")
    let end_com = substitute(end_com, "*", "\\\\*", "g")
    let pos = col('.')
    let ll = len(getline('.'))
    let offset = min([(ll-pos), cs])
    let command = command . "s/^\\(\\s*\\)" . open_com . "\\(.*\\)" . end_com . "$" . "/\\1\\2/"
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

function! PythonInstanceVars()
    normal! ma
    normal! $
    try
        call search("def __init__", "b")
        let start = line(".")
    catch
        normal! `a
        return
    endtry
    call search("^\s*$", "W")
    if line(".") != start
        let end = line(".") - 1
    else
        normal! G
        let end = line(".")
    endif
    let command = start . "," . end . " !python3 ~/bin/PythonInstanceVars.py" 
    silent exe command
    normal! `a
endfunction

"---------------------------------------------
"-------------------Section-------------------
"-------------------Plugins-------------------
"---------------------------------------------

"ultisnips triggers
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

"syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0


"---------------------------------------------
"-------------------Section-------------------
"-------------------Autocmds------------------
"---------------------------------------------

augroup MyAutocmds
    au!

    autocmd GUIEnter * set noerrorbells visualbell t_vb=

    "remove preview window after auto-completion
"    autocmd CompleteDone * pclose

    "no autocomment on next line after comment
    autocmd FileType * set formatoptions-=c formatoptions-=r formatoptions-=o 

    "resize windows when vim is resized
    autocmd VimResized * wincmd =

    "different tab sizes
    autocmd FileType python set softtabstop=4
    autocmd FileType python set shiftwidth=4

    "----------------------
    "---------html---------
    "----------------------
    "skeleton
    autocmd BufNewFile *.html 0r $HOME/.vim/.skeleton.html
    "complete tag
    autocmd FileType html inoremap <silent> <buffer> <NUL> </<C-x><C-o><Down><CR>
    autocmd FileType html inoremap <silent> <buffer> <C-f> <ESC>/><CR>a
    autocmd FileType html inoremap <silent> <buffer> <C-b> <ESC>?<<CR>?><CR>a

    "----------------------
    "------javascript------
    "----------------------
    "skeleton
    autocmd BufNewFile *.js 0r $HOME/.vim/.skeleton.js
    "run program
    autocmd FileType javascript nnoremap <silent> <buffer> <leader>rn :!clear <CR><CR>:w<CR> :!nodejs %<CR>
    "run program and pipe to less
    autocmd FileType javascript nnoremap <silent> <buffer> <leader>Rn :!clear <CR><CR>:!nodejs % \| less<CR>
    "tern jump to definition
    autocmd FileType javascript nnoremap <silent> <buffer> <leader>d :TernDef<Cr>
    "tern documentation
    autocmd FileType javascript nnoremap <silent> <buffer> <S-k> :TernDoc<Cr>

    "----------------------
    "--------python--------
    "----------------------
    "run program in repl
    autocmd FileType python nnoremap <silent> <buffer> <leader>rn :!clear <CR><CR>:w<CR> :!python3 -i %<CR>
    "run program and pipe output to less
    autocmd FileType python nnoremap <silent> <buffer> <leader>Rn :!clear <CR><CR>:!python3 % \| less<CR>
    "insert instance variables
    "autocmd FileType python noremap <silent> <buffer> <leader>va :call PythonInstanceVars()<CR>
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
    "----------c-----------
    "----------------------
    "skeleton
    autocmd BufNewFile *.c 0r $HOME/.vim/.skeleton.c
    "make sure headers are classified as c files and not cpp files
    autocmd BufRead,BufNewFile *.h set filetype=c
    "compile
    autocmd FileType c nnoremap <silent> <buffer> <leader>mk :!clear<CR><CR>:w<CR> :!gcc %<CR>
    "run program
    autocmd FileType c nnoremap <silent> <buffer> <leader>rn :!clear<CR><CR>:!valgrind ./a.out<CR>
    "run program and pipe to less
    autocmd FileType c nnoremap <silent> <buffer> <leader>Rn :!clear<CR><CR>:!valgrind ./a.out \| less<CR>

    "----------------------
    "-------scheme---------
    "----------------------
    "run in rep
    autocmd FileType scheme nnoremap <silent> <buffer> <leader>rn :!clear <CR><CR>:w<CR> :!csi %<CR>


    "----------------------
    "---------sml----------
    "----------------------
    "load in repl
    autocmd FileType sml nnoremap <silent> <buffer> <leader>repl :!sml %<CR>
    "comment
    autocmd FileType sml vnoremap <buffer> <leader>cc :<C-U>call AddTwoPartComment(1, "(* ", " *)")<CR>
    autocmd FileType sml nnoremap <buffer> <leader>cc :<C-U>call AddTwoPartComment(0, "(* ", " *)")<CR>
    "uncomment
    autocmd FileType sml vnoremap <buffer> <leader>cu :<C-U>call RemoveTwoPartComment(1, "(* ", " *)")<CR>
    autocmd FileType sml nnoremap <buffer> <leader>cu :<C-U>call RemoveTwoPartComment(0, "(* ", " *)")<CR>
    autocmd FileType sml inoremap <silent> <buffer> <NUL><NUL> \|<TAB>

augroup END
