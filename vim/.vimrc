set number
set nocompatible
syntax on
set showmode
set showcmd
set encoding=utf-8
set t_Co=256
filetype indent on
set autoindent
set tabstop=4
set expandtab
set softtabstop=4
set relativenumber
"set cursorline
"set wrap
"set wrapmargin=2
"set laststatus=2
set ruler
"set showmatch
"set hlsearch
set incsearch

call plug#begin('~/.vim/plugged')
Plug 'arcticicestudio/nord-vim'
"Plug 'itchyny/lightline.vim'
Plug 'vim-airline/vim-airline'
call plug#end()

let g:airline_powerline_fonts = 1

colorscheme nord
