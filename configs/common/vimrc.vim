set nocompatible
source ~/.vimrc.pre.vim
let s:is_windows = has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_mac = !s:is_windows && !s:is_cygwin
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!executable('xdg-open') &&
      \     system('uname') =~? '^darwin'))
let s:is_macvim = has('gui_macvim')
if s:is_windows
    set rtp+=~/.vim
    if has('+shellslash')
        set shellslash
    endif
endif
if !exists('g:machine')
    let g:machine = 'unknown'
endif
if !exists('g:cpp_expandtab')
    let g:cpp_expandtab = 1
endif
if !exists('g:cpp_textwidth')
    let g:cpp_textwidth = 100
endif
let mapleader = ','
let g:mapleader = ','

if filereadable(getcwd().'/tags')
    exec 'set tags+='.fnameescape(getcwd()).'/tags'
endif
if filereadable(getcwd().'/cscope.out')
    exec 'cscope add '.fnameescape(getcwd()).'/cscope.out'
endif
" The below 2 filetype lines fix return code of vim on Mac OS X, when using pathogen.
" http://andrewho.co.uk/weblog/vim-pathogen-with-mutt-and-git
filetype on
filetype off
set rtp+=~/.vim/bundle/neobundle.vim/
call neobundle#rc(expand('~/.vim/bundle'))
" Dependencies
NeoBundleFetch 'Shougo/neobundle.vim'
NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/vimshell'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'thinca/vim-quickrun'
" Syntax
NeoBundle 'http://svn.macports.org/repository/macports/contrib/mpvim/'
NeoBundle 'vim-scripts/Boost-Build-v2-BBv2-syntax'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'chikamichi/mediawiki.vim'
NeoBundle 'tpope/vim-markdown'
NeoBundle 'bling/vim-airline'
" Programming
NeoBundle 'tpope/vim-git'
NeoBundle 'bogado/file-line'
NeoBundle 'ujihisa/repl.vim'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/unite-build'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'vim-scripts/Rainbow-Parentheses-Improved-and2'
" Haskell
NeoBundle 'feuerbach/vim-hs-module-name'
NeoBundle 'Twinside/vim-haskellConceal'
NeoBundle 'eagletmt/unite-haddock'
NeoBundle 'eagletmt/ghcmod-vim'
NeoBundle 'ujihisa/neco-ghc'
" C++
NeoBundle 'Valloric/YouCompleteMe', {'vim_version':'7.3.584'}
" Python
NeoBundle 'nvie/vim-flake8'
" Text
NeoBundle 'kana/vim-fakeclip'
NeoBundle 'godlygeek/tabular'
NeoBundle 'tpope/vim-surround'
NeoBundle 'Lokaltog/vim-easymotion'
"NeoBundle 'terryma/vim-multiple-cursors'
" Files
NeoBundle 'mhinz/vim-startify'
NeoBundle 'Shougo/vimfiler.vim'
NeoBundle 'Shougo/unite-sudo'
" Config
call neobundle#config('neocomplete.vim', {
      \ 'lazy' : 1,
      \ 'autoload' : {
      \   'insert' : 1,
      \ }})
call neobundle#config('unite.vim',{
      \ 'lazy' : 1,
      \ 'autoload' : {
      \   'commands' : [{ 'name' : 'Unite',
      \                   'complete' : 'customlist,unite#complete_source'},
      \                 'UniteWithCursorWord', 'UniteWithInput']
      \ }})
call neobundle#config('vimproc', {
      \ 'build' : {
      \     'windows' : 'make -f make_mingw32.mak',
      \     'cygwin' : 'make -f make_cygwin.mak',
      \     'mac' : 'make -f make_mac.mak',
      \     'unix' : 'make -f make_unix.mak',
      \    },
      \ })
call neobundle#config('vimshell', {
      \ 'lazy' : 1,
      \ 'autoload' : {
      \   'commands' : [{ 'name' : 'VimShell',
      \                   'complete' : 'customlist,vimshell#complete'},
      \                 'VimShellExecute', 'VimShellInteractive',
      \                 'VimShellTerminal', 'VimShellPop'],
      \   'mappings' : ['<Plug>(vimshell_switch)']
      \ }})
NeoBundleCheck

" Syntax highlighting on
if has('syntax')
    syntax enable
    if exists(':highlight')
        highlight DiffAdd ctermfg=0 ctermbg=2 guibg='green'
        highlight DiffDelete ctermfg=0 ctermbg=1 guibg='red'
        highlight DiffChange ctermfg=0 ctermbg=3 guibg='yellow'
    endif
endif
let g:solarized_termcolors=256
set t_Co=256
set background=dark
" See :h filetype-overview
filetype plugin indent on
colorscheme solarized
if g:colors_name != 'solarized'
    colorscheme blackboard
endif
set nonumber
set textwidth=79
set tabstop=4
set shiftwidth=4
set expandtab
set listchars=nbsp:~,tab:>\ ,precedes:<,extends:>
set matchpairs+=<:>
" Don't automatically format text as it's typed.
set formatoptions-=t
" When 'wrap' is enabled, use 'soft wrap', i.e., don't insert an eol into the buffer.
set linebreak
set nowrap
" The movements can travel across line breaks.
set whichwrap=h,l,~,[,]
" Allow <BkSpc> to delete beyond the start of the current insertion, and over indentations.
set backspace=start,indent
if exists('$TMUX')
    set clipboard=
else
    " Sync with OS clipboard.
    set clipboard=unnamed
endif
" Show matching brackets.
set showmatch
if exists('+undofile')
    set undofile
    set undodir=~/.vim/.cache/undo
endif
set backupdir=~/.vim/.cache/backup
" Swap files all go into ~/.vim/swap if it exists.
set directory=~/.vim/.cache/swap
function! EnsureExists(path)
    if !isdirectory(expand(a:path))
        call mkdir(expand(a:path))
    endif
endfunction
call EnsureExists('~/.vim/.cache')
call EnsureExists(&undodir)
call EnsureExists(&backupdir)
call EnsureExists(&directory)
" Keep 1000 file marks, 500 lines of registers max.
if version >= 700
    set viminfo='1000,f1,<500
endif
set autoindent
set nohlsearch
set incsearch
" Minimum number of lines the search result may be from the top/bottom.
set scrolloff=10
set smartcase
set undolevels=200
set history=100
" Show what mode we're in at all times.
set showmode
" Path/file matching in command mode like bash's.
set wildmode=longest,list
set wildchar=<TAB>
set wildignore+=*/.git*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store
" Show a tab through menu.
set wildmenu
set printoptions=paper:a4
if exists('+autochdir')
    set autochdir
elseif has("autocmd")
    autocmd BufEnter * silent! lcd fnameescape(expand('%:p:h'))
endif
set novisualbell
set noerrorbells
if s:is_macvim
    set vb " workaround to get rid of audible bell. still no visualbell :D
endif
if s:is_windows && !s:is_cygwin
    set shell=c:\windows\system32\cmd.exe
endif
" Make c-u and c-w start a new change before running.
" http://vim.wikia.com/wiki/Recover_from_accidental_Ctrl-U
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
noremap Y y$
" <HOME> toggles between start of line and start of text
imap <khome> <home>
nmap <khome> <home>
function! Home()
    let curcol = wincol()
    normal 0
    let newcol = wincol()
    if newcol == curcol
        normal ^
    endif
endfunction
inoremap <silent> <home> <C-o>:call Home()<CR>
nnoremap <silent> <home> :call Home()<CR>
" Scroll left-right.
nnoremap <C-l> zl
nnoremap <C-h> zh

nnoremap <Leader>rr :redraw!<CR>
nnoremap <Leader>tn :set invnumber number?<CR>
nnoremap <Leader>tp :set invpaste paste?<CR>
nnoremap <Leader>tw :set invwrap wrap?<CR>
nnoremap <Leader>th :set invhls hls?<CR>
" toggle hard line wrapping at textwidth on and off
nnoremap <Leader>tf :if &fo =~ 't' <Bar> set fo-=t <Bar> else <Bar> set fo+=t <Bar>
  \ endif <Bar> set fo?<CR>
nnoremap <Leader>tl :set invlist list?<CR>
nnoremap <Leader>ts :set invspell spell?<CR>
nnoremap <Leader>tw :set invwrap wrap?<CR>

nnoremap <Leader>cc :make!<CR> <Bar> :copen<CR>
nnoremap <Leader>cn :cnext<CR>
nnoremap <Leader>cp :cprev<CR>
nnoremap <Leader>ci :copen<Cr>
if has('multi_byte')
    " quotation dash
    digraphs -Q 8213
    " figure dash
    digraphs -F 8210
    " e.g., Polish as in Grze<c-k>'s
    digraphs 's 347
    digraphs s' 347
endif
if has('cmdline_info')
    set ruler
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
    " Show number of chars/lines in visual selection.
    set showcmd
endif
if has('statusline')
    " Show statusline only if there are > 1 windows.
    set laststatus=1
    " From spf13-vim
    " Broken down into easily includeable segments.
    set statusline=%<%f\    " Filename
    set statusline+=%w%h%m%r " Options
    "set statusline+=%{fugitive#statusline()} "  Git Hotness
    set statusline+=\ [%{&ff}/%Y]            " filetype
    set statusline+=\ [%{getcwd()}]          " current dir
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    "my original set statusline=%<%f\ %=\:\b%n%y%m%r%w\ %l,%c%V\ %P
    set shortmess+=r
endif

if has("autocmd")
    autocmd BufNew *
        \   if &buftype == 'quickfix' |
        \       setlocal wrap |
        \   endif
    if !exists('filetypeextras_loaded')
        let filetypeextras_loaded = 1
        augroup filetypeextras
            autocmd FileType pandoc,markdown runtime ftplugin/txt.vim
            autocmd FileType c,objc,objcpp runtime ftplugin/cpp.vim
            autocmd FileType perl       setlocal smartindent
            autocmd FileType make       setlocal noexpandtab sw=8 ts=8
            " Redraw rainbow parens when going back to the buffer.
            autocmd Syntax * call rainbow#load()
        augroup end
    endif
    if !exists('filetypedetect_loaded')
        let filetypedetect_loaded = 1
        augroup filetypedetect
            autocmd BufRead,BufNewFile *.text,*.txt,*.mail,*.email,*.followup,*.article,*.letter,/tmp/pico*,nn.*,snd.*,/tmp/mutt* setlocal filetype=txt
            autocmd BufRead,BufNewFile Jamfile,Jamroot,*.jam setlocal filetype=bbv2
            " .m files are objective c by default, not matlab
            autocmd BufRead,BufNewFile *.m setlocal filetype=objc
            " .proto files for google protocol buffers
            autocmd BufRead,BufNewFile *.proto setlocal filetype=proto
        augroup end
    endif
endif

" ("diff no") turn off diff mode and report the change
nnoremap <Leader>dn :if &diff <Bar> diffoff <Bar> echo 'diffoff' <Bar> else <Bar> echo 'not in diff mode' <Bar> endif<CR>
" ("diff obtain") do :diffget on range and report the change:
" use "diff obtain" as that's what Vim itself uses for the non-range command: do
vnoremap <Leader>do :diffget <Bar> echo 'Left >>> Right'<CR>
" ("diff put") do :diffput on range and report the change:
vnoremap <Leader>dp :diffput <Bar> echo 'Left <<< Right'<CR>
" Remap arrow keys.
nnoremap <down> :bprev<CR>
nnoremap <up> :bnext<CR>
nnoremap <left> :tabnext<CR>
nnoremap <right> :tabprev<CR>
" Change cursor position in insert mode.
inoremap <C-h> <left>
inoremap <C-l> <right>

function! AutoGitCommit(filename)
	execute 'silent! !git commit -m autocommit\ '.fnameescape(fnamemodify(a:filename, ':p:t')).' '.fnameescape(a:filename)
endfunction
" 'AutoGitCommitWrites %:t' will run AutoGitCommit on each write
" Could be used in conjunction with set autowriteall
command! -nargs=1 -complete=file AutoGitCommitWrites
      \ autocmd BufWritePost <args> call AutoGitCommit(expand('<afile>:p'))

command! WUtf8 setlocal fenc=utf-8
command! WUtf16 setlocal fenc=ucs-2le
command! -bang -complete=file -nargs=? WUnix
      \ write<bang> ++fileformat=unix <args> | edit <args>
command! -bang -complete=file -nargs=? WDos
      \ write<bang> ++fileformat=dos <args> | edit <args>
command! -bang -complete=file -nargs=? WMac
      \ write<bang> ++fileformat=mac <args> | edit <args>

" DiffOrig makes a diff with swap file and current version
if !exists(":DiffOrig")
  command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

function! GavFound(toexist, tobefound, ...)
    if exists(a:toexist)
        if empty(a:000)
            exec a:toexist
        else
            exec a:1
        endif
    else
        echohl WarningMsg
        echo a:tobefound . " was not found."
        echohl None
    endif
endfunction
" fswitch plugin macros
nnoremap <Leader>fs :call GavFound(":FSHere", "fswitch")<CR>
nnoremap <Leader>fv :call GavFound(":FSSplitRight", "fswitch")<CR>
" gnupg options
let g:GPGPreferArmor = 1
" svndiff plugin macros
nnoremap <silent> <Leader>vn :if exists('*Svndiff') <Bar> :call Svndiff("next") <Bar> endif<CR>
nnoremap <silent> <Leader>vp :if exists('*Svndiff') <Bar> :call Svndiff("prev") <Bar> endif<CR>
nnoremap <silent> <Leader>vc :if exists('*Svndiff') <Bar> :call Svndiff("clear") <Bar> endif<CR>
" pyflakes-vim highlighting
augroup pyflakesfiletypedetect
    au! FileType python highlight SpellBad term=underline ctermfg=Magenta gui=undercurl guisp=Orange
augroup END
" Ag
if executable('ag')
    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
endif
" Unite plugin
let g:unite_enable_start_insert = 1
let g:unite_source_history_yank_enable = 1
let g:unite_source_rec_max_cache_files = 5000
let g:unite_data_directory = '~/.vim/.cache/unite'
call EnsureExists('~/.vim/.cache/unite')
call unite#set_profile('files', 'smartcase', 1)
if executable('ag')
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nocolor --nogroup -S -C4'
    let g:unite_source_grep_recursive_opt = ''
elseif executable('ack')
    let g:unite_source_grep_command = 'ack'
    let g:unite_source_grep_default_opts = '--no-heading --no-color -a -C4'
    let g:unite_source_grep_recursive_opt = ''
endif
if s:is_windows
    nnoremap <silent> <leader><space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec buffer file_mru bookmark<cr><c-u>
    nnoremap <silent> <leader>f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec<cr><c-u>
else
    nnoremap <silent> <leader><space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async buffer file_mru bookmark<cr><c-u>
    nnoremap <silent> <leader>f :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec/async<cr><c-u>
endif
nnoremap <silent> <leader>y :<C-u>Unite -buffer-name=yanks history/yank<cr>
nnoremap <silent> <leader>l :<C-u>Unite -auto-resize -buffer-name=line line<cr>
nnoremap <silent> <leader>b :<C-u>Unite -auto-resize -buffer-name=buffers buffer<cr>
nnoremap <silent> <leader>/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
nnoremap <silent> <leader>m :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
nnoremap <silent> <leader>s :<C-u>Unite -quick-match buffer<cr>
" vim-fugitive
nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gb :Gblame<CR>
nnoremap <silent> <leader>gl :Glog<CR>
nnoremap <silent> <leader>gp :Git push<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>gr :Gremove<CR>
autocmd FileType gitcommit nmap <buffer> U :Git checkout -- <C-r><C-g><CR>
autocmd BufReadPost fugitive://* set bufhidden=delete"
" Various Haskell options.
let g:haskell_autotags = 1
let g:haskell_tabular = 1
let g:haskell_conceal = 1
let g:haskell_conceal_comments = 1
let g:haskell_conceal_enumerations = 1
let g:haskell_conceal_wide = 1
let g:haskell_interpolation = 1
let g:haskell_tags_generator = 1
let g:haskell_ffi = 1
let g:hpaste_author = 'gavinbeatty'
let g:haddock_browser = 'sensible-browser'
let g:pandoc_no_folding = 1
" vim-indent-guides
let g:indent_guides_start_level=1
let g:indent_guides_guide_size=1
let g:indent_guides_enable_on_vim_startup=0
let g:indent_guides_color_change_percent=3
if !has('gui_running')
    let g:indent_guides_auto_colors=0
    function! s:indent_set_console_colors()
        hi IndentGuidesOdd ctermbg=235
        hi IndentGuidesEven ctermbg=236
    endfunction
    autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
endif
" vim-startify
let g:startify_list_order = ['files', 'dir', 'bookmarks', 'sessions']
let g:startify_bookmarks = ['~/work/gavinbeatty/configs/common/vimrc.vim']
let g:ycm_key_list_select_completion=['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion=['<C-p>', '<Up>']
let g:ycm_filetype_blacklist={'unite': 1}
" rainbow operators"
let g:rainbow_active = 1
let g:rainbow_operators = 1

" gvim specific options
if has('gui_running')
    " remove toolbar
    set guioptions-=T          " remove: T, the toolbar
    " remove left-hand toolbar in vsplit
    " this fixes a bug where caret
    " disappears in vsplit in 7.2
    set guioptions-=L
    set lines=30
    let g:font = 'Bitstream\ Vera\ Sans\ Mono'
    "let g:font = 'Monospace'
    let g:fontpt = 10
    function! SetFont()
        exec ':set guifont=' . g:font . '\ ' . g:fontpt
    endfun
    function! IncrFontPt()
        let g:fontpt = g:fontpt + 1
        call SetFont()
    endfun
    function! DecrFontPt()
        let g:fontpt = g:fontpt - 1
        call SetFont()
    endfun
    call SetFont()
    " hold right click for the usual kind of menu
    set mousemodel=popup
    nmap <F11> :call IncrFontPt()<CR>
    nmap <F10> :call DecrFontPt()<CR>
    nmap <Leader>fi :call IncrFontPt()<CR>
    nmap <Leader>fd :call DecrFontPt()<CR>
endif
source ~/.vimrc.unicode.vim
source ~/.vimrc.post.vim
