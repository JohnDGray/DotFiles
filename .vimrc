" The default vimrc file.
"
" Maintainer:	Bram Moolenaar <Bram@vim.org>
" Last change:	2019 Feb 18
"
" This is loaded if no vimrc file was found.
" Except when Vim is run with "-u NONE" or "-C".
" Individual settings can be reverted with ":set option&".
" Other commands can be reverted as mentioned below.

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

" Bail out if something that ran earlier, e.g. a system wide vimrc, does not
" want Vim to use these default values.
if exists('skip_defaults_vim')
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
" Avoid side effects when it was already reset.
if &compatible
  set nocompatible
endif

" When the +eval feature is missing, the set command above will be skipped.
" Use a trick to reset compatible only when the +eval feature is missing.
silent! while 0
  set nocompatible
silent! endwhile

" Allow backspacing over everything in insert mode.
set backspace=indent,eol,start

set history=200		" keep 200 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set wildmenu		" display completion matches in a status line

set ttimeout		" time out for key codes
set ttimeoutlen=100	" wait up to 100ms after Esc for special key

" Show @@@ in the last line if it is truncated.
set display=truncate

" Show a few lines of context around the cursor.  Note that this makes the
" text scroll if you mouse-click near the start or end of the window.
set scrolloff=5

" Do incremental searching when it's possible to timeout.
if has('reltime')
  set incsearch
endif

" Do not recognize octal numbers for Ctrl-A and Ctrl-X, most users find it
" confusing.
set nrformats-=octal

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries.
if has('win32')
  set guioptions-=t
endif

" Don't use Ex mode, use Q for formatting.
" Revert with ":unmap Q".
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
" Revert with ":iunmap <C-U>".
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine.  By enabling it you
" can position the cursor, Visually select and scroll with the mouse.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on when the terminal has colors or when using the
" GUI (which always has colors).
if &t_Co > 2 || has("gui_running")
  " Revert with ":syntax off".
  syntax on

  " I like highlighting strings inside C comments.
  " Revert with ":unlet c_comment_strings".
  let c_comment_strings=1
endif

" Only do this part when Vim was compiled with the +eval feature.
if 1

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  " Revert with ":filetype off".
  filetype plugin indent on

  " Put these in an autocmd group, so that you can revert them with:
  " ":augroup vimStartup | au! | augroup END"
  augroup vimStartup
    au!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif

  augroup END

endif

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
" Revert with: ":delcommand DiffOrig".
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

if has('langmap') && exists('+langremap')
  " Prevent that the langmap option applies to characters that result from a
  " mapping.  If set (default), this may break plugins (but it's backward
  " compatible).
  set nolangremap
endif

"---------------------------------------------------------------
"--------------------------My Settings--------------------------
"---------------------------------------------------------------

"---------------------------------------------------------------
"----------------------------General----------------------------
"---------------------------------------------------------------

let mapleader="\<SPACE>"

"color scheme and syntax highlighting stuff
"syntax enable
if isdirectory(expand("$HOME") . "/.vim/pack/my-plugins/start/gruvbox")
  set background=dark
  "let g:gruvbox_contrast_dark="hard"
  colorscheme gruvbox
  hi Normal ctermbg=NONE
else
  colorscheme elflord
endif

"shut up vim
set noerrorbells visualbell t_vb=

"tab stuff
set softtabstop=2
set shiftwidth=2
set expandtab

"indent at same level as last line
set autoindent

"make splitting more natural
set splitbelow
set splitright

"status line
"always show status
set laststatus=2
"include buffer number and file name in status line
set statusline+=%n\ %F
set statusline+=%=

"highlighting
"highlight all search matches
set hlsearch
"turn off hlsearch when redrawing
nnoremap <C-l> :nohlsearch<CR><C-l>

"show line numbers
set number


"-----------------------------------------------------------------
"---------------------------Shortcuts-----------------------------
"-----------------------------------------------------------------
"use very magic and ignore case
nnoremap / /\v\c

"-----------------------------------------------------------------
"---------------------------Plugins------------------------------
"-----------------------------------------------------------------
if isdirectory(expand("$HOME") . "/.vim/pack/my-plugins/start/vim-snippets/UltiSnips")
  let g:UltiSnipsExpandTrigger="<tab>"
  let g:UltiSnipsJumpForwardTrigger="<tab>"
  let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
endif

"-----------------------------------------------------------------
"-------------------------Auto Commands---------------------------
"-----------------------------------------------------------------
augroup MyAutocmds
  au!

  "autocmd GUIEnter * set noerrorbells visualbell t_vb=

  "resize windows when vim is resized
  autocmd VimResized * wincmd =

  "python tab stuff
  autocmd FileType python set softtabstop=4
  autocmd FileType python set shiftwidth=4

  autocmd BufRead *.html set filetype+=.javascript

  "python run file
  if !system('which ipython3 >> /dev/null; echo $?;')
    autocmd FileType python nnoremap <leader>ppt :!ipython3 -i %<CR>
    autocmd FileType python nnoremap <leader>ppi :!ipython3<CR>
  else
    autocmd FileType python nnoremap <leader>ppt :!python3 -i %<CR>
    autocmd FileType python nnoremap <leader>ppi :!python3<CR>
  endif

  autocmd FileType python nnoremap <leader>ppl :!python3 % \| less<CR>

  autocmd FileType cpp nnoremap <leader>c :!g++ %<CR>
  autocmd FileType cpp nnoremap <leader>r :!./a.out<CR>

augroup END
