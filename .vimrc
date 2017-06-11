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
set statusline+=%{getcwd()}

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
"set omnifunc=syntaxcomplete#Complete
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
    end
    return ""
endfunction

nnoremap <leader><leader> n<ESC>3s

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
command! MakeTags !ctags -R --exclude=.git .

"Search parent directories for tags as well
set tags=./tags,tags;

"Google word shortcut
nnoremap <leader>go :call Google(0)<CR>
vnoremap <leader>go "ay :call Google(1)<CR>

function! Google(visual)
    let ss = GetLanguage()
    if (&ft == "html")
        let ss = ss . "\\<"
    endif
    if a:visual
        let text = join(split(@a), "+")
        let ss = ss . text
    else
        let ss = ss . expand("<cword>")
    endif
    if (&ft == "html")
        let ss = ss . "\\>"
    endif
    let ss = substitute(ss, "(", "\\\\(", "g") 
    let ss = substitute(ss, ")", "\\\\)", "g") 
    let ss = substitute(ss, "<", "\\\\<", "g") 
    let ss = substitute(ss, ">", "\\\\>", "g") 
    let ss = substitute(ss, "|", "\\\\|", "g") 
    let ss = substitute(ss, "!", "\\\\!", "g") 
    let ss = substitute(ss, "&", "\\\\&", "g") 
    let ss = substitute(ss, ";", "\\\\;", "g") 
    exe "!firefox -P alt " . "https://www.google.com/search?q=" . ss
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

function! TagJump(display_func)
"    :spl
    let word = expand("<cword>")
    try
        exe "stj " . word
"        exe a:display_func
"        :wincmd p
    catch
"        :q
        :echo "Could not display definition for: " . word
        return
    endtry
    :wincmd p
endfunction

set noshowmode
"---------------------------------------------
"-------------------Section-------------------
"-------------------Plugins-------------------
"---------------------------------------------
"don't try to autocomplete on import statement
"let g:jedi#smart_auto_mappings = 0

"don't show method signature
let g:jedi#show_call_signatures = 2

"don't popup on dot
let g:jedi#popup_on_dot = 0

"disable go to definition
let g:jedi#goto_command = ""

"automatically lint on javascript files on save
let jshint2_save = 1

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

    autocmd BufWritePost  * silent exe "!UpdateTags.sh ."

    "no autocomment on next line after comment
    autocmd FileType * set formatoptions-=c formatoptions-=r formatoptions-=o 

    "colorful status line
    hi statusline ctermfg=67

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
    "autocomplete
    autocmd FileType javascript inoremap <buffer> <expr> <NUL> Auto_complete_string()
    "tern definition
    autocmd FileType javascript nnoremap <buffer> <silent> <leader>d :call TagJump("TernDef")<CR>
    "tern documentation
    autocmd FileType javascript nnoremap <buffer> K :TernDoc<CR>
    "tern usages/references
    autocmd FileType javascript nnoremap <buffer> <leader>n :TernRefs<CR>

    "---------------
    "---au-python---
    "---------------
    "run program
    autocmd FileType python nnoremap <buffer> <leader>run :!clear <CR><CR>:!python %<CR>
    "run program and pipe output to less
    autocmd FileType python nnoremap <buffer> <leader>lrun :!clear <CR><CR>:!python % \| less<CR>
    "jedi definition
    autocmd FileType python nnoremap <buffer> <silent> <leader>d :call TagJump("call jedi#goto()")<CR>
    "lint on write
    autocmd BufWritePost *.py call Flake8()
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
