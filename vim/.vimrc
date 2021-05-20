set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
plugin 'vim-airline/vim-airline'
plugin 'arcticicestudio/nord-vim'
plugin 'valloric/youcompleteme'
plugin 'sheerun/vim-polyglot'
plugin 'junegunn/fzf', { 'do': { -> fzf#install() } }
plugin 'junegunn/fzf.vim'
call vundle#end()

let mapleader=' '
set number
set nocompatible
syntax enable
set showmode
set showcmd
set encoding=utf-8
set t_co=256
filetype indent on
filetype plugin on
set autoindent
set tabstop=4
set expandtab
set softtabstop=4
set relativenumber
"set cursorline
""set wrap
"set wrapmargin=2
""set laststatus=2
set ruler
"set showmatch
set hlsearch
set incsearch

"move around the windows
nnoremap <c-h> <c-w><c-h>
nnoremap <c-j> <c-w><c-j>
nnoremap <c-k> <c-w><c-k>
nnoremap <c-l> <c-w><c-l>

"split window"
set splitbelow
set splitright
nnoremap <c-s> <c-w><c-s>
nnoremap <c-s>v <c-w><c-v>

"fzf shortcuts"
nnoremap <space>f :files<cr>

"youcompleteme shortcuts"
nnoremap <space>j :vertical ycmcompleter gotodefinition<cr>

"buffer shortcuts
nnoremap ls :ls<cr>
nnoremap bn :bnext<cr>
nnoremap bn :bnext<cr>

"resize vim windows"
nnoremap <silent> <s-k> <c-w>+
nnoremap <silent> <s-j> <c-w>-
nnoremap <silent> <s-h> <c-w><
nnoremap <silent> <s-l> <c-w>>
nnoremap <silent> <s-=> <c-w>=

let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts=1
colorscheme nord

let g:fzf_colors =
\ { 'fg':      ['fg', 'normal'],
\ 'bg':      ['bg', 'normal'],
\ 'hl':      ['fg', 'comment'],
\ 'fg+':     ['fg', 'cursorline', 'cursorcolumn', 'normal'],
\ 'bg+':     ['bg', 'cursorline', 'cursorcolumn'],
\ 'hl+':     ['fg', 'statement'],
\ 'info':    ['fg', 'preproc'],
\ 'border':  ['fg', 'ignore'],
\ 'prompt':  ['fg', 'conditional'],
\ 'pointer': ['fg', 'exception'],
\ 'marker':  ['fg', 'keyword'],
\ 'spinner': ['fg', 'label'],
\ 'header':  ['fg', 'comment'] }

let g:ycm_goto_buffer_command = 'split'

