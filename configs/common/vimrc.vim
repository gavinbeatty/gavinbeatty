set nocompatible
let s:is_windows = has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_mac = !s:is_windows && !s:is_cygwin
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!executable('xdg-open') &&
      \     system('uname') =~? '^darwin'))
let s:is_macvim = has('gui_macvim')
source ~/.vimrc.pre.vim
if !exists('g:machine') | let g:machine = 'unknown' | endif
if !exists('g:cpp_expandtab') | let g:cpp_expandtab = 1 | endif
if !exists('g:cpp_textwidth') | let g:cpp_textwidth = 100 | endif
if !exists('mapleader') | let mapleader = ',' | endif
if !exists('g:mapleader') | let g:mapleader = ',' | endif

let &tags = getcwd().'/tags,'
set nocscopeverbose
exec 'cscope add '.fnameescape(getcwd().'/cscope.out')
set cscopeverbose

" The below 2 filetype lines fix return code of vim on Mac OS X, when using pathogen.
" http://andrewho.co.uk/weblog/vim-pathogen-with-mutt-and-git
" I leave them here, even though I now use neobundle.
filetype on
filetype off
if s:is_windows | set rtp+=~/.vim | endif
set rtp+=~/.vim/bundle/neobundle.vim/
call neobundle#rc(expand('~/.vim/bundle'))
NeoBundleFetch 'Shougo/neobundle.vim'
" Dependencies
NeoBundle 'Shougo/vimproc'
NeoBundle 'Shougo/vimshell'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'thinca/vim-quickrun'
" Syntax
NeoBundle 'http://svn.macports.org/repository/macports/contrib/mpvim/'
NeoBundle 'vim-scripts/Boost-Build-v2-BBv2-syntax'
NeoBundle 'altercation/vim-colors-solarized'
NeoBundle 'ujihisa/unite-colorscheme'
NeoBundle 'chikamichi/mediawiki.vim'
NeoBundle 'tpope/vim-markdown'
NeoBundle 'bling/vim-airline'
" Programming
NeoBundle 'tpope/vim-git'
NeoBundle 'bogado/file-line'
NeoBundle 'Shougo/unite.vim'
NeoBundle 'Shougo/unite-build'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'Raimondi/delimitMate'
NeoBundle 'derekwyatt/vim-fswitch'
NeoBundle 'nathanaelkane/vim-indent-guides'
NeoBundle 'vim-scripts/Rainbow-Parentheses-Improved-and2'
" Haskell
NeoBundle 'vim-scripts/Superior-Haskell-Interaction-Mode-SHIM'
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
" NeoBundle options
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

syntax enable
highlight DiffAdd ctermfg=0 ctermbg=2 guibg='green'
highlight DiffDelete ctermfg=0 ctermbg=1 guibg='red'
highlight DiffChange ctermfg=0 ctermbg=3 guibg='yellow'
let g:solarized_termcolors=256
set t_Co=256
set background=dark
" See :h filetype-overview
filetype plugin indent on
colorscheme solarized
if g:colors_name != 'solarized' | colorscheme blackboard | endif
set nonumber
set expandtab
set tabstop=4
set shiftwidth=4
set textwidth=90
set matchpairs+=<:>
set showmatch
set listchars=nbsp:~,tab:>\ ,precedes:<,extends:>
set nolist
" Don't automatically format text as it's typed.
set formatoptions-=t
" When 'wrap' is enabled, use 'soft wrap', i.e., don't insert an eol into the buffer.
set linebreak
set nowrap
" The movements can travel across line breaks.
set whichwrap=h,l,~,[,]
" Allow <BkSpc> to delete beyond the start of the current insertion & over indentations.
set backspace=start,indent
" Keep 1000 file marks, 500 lines of registers max.
set viminfo='1000,f1,<500
set history=100
set undolevels=200
set autoindent
set smartcase
set nohlsearch
set incsearch
" Minimum number of lines the search result may be from the top/bottom.
set scrolloff=10
set showmode
" Path/file matching in command mode like bash's.
set wildmode=longest,list
set wildchar=<TAB>
set wildignore+=*/.git*,*/.hg/*,*/.svn/*,*/.bzr/*,*/.idea/*,*/.DS_Store
" Show a tab through menu.
set wildmenu
set printoptions=paper:a4
set novisualbell
set noerrorbells
" Workaround to get rid of audible bell, that doesn't actually enable visual bell.
if s:is_macvim | set visualbell | endif
" Sync with OS clipboard outside tmux.
if exists('$TMUX') | set clipboard=
else | set clipboard=unnamed | endif
" I have no clue how to do single-line if-elseif-endif in vimscript.
if exists('+autochdir')
    set autochdir
elseif has("autocmd")
    autocmd BufEnter * sil! lcd fnameescape(expand('%:p:h'))
endif
if s:is_windows && has('+shellslash') | set shellslash | endif

fu! EnsureDirExists(path)
    sil! call mkdir(expand(a:path), 'p')
endf
if exists('+undofile') | set undofile | set undodir=~/.vim/.cache/undo | endif
set backupdir=~/.vim/.cache/backup
set directory=~/.vim/.cache/swap
call EnsureDirExists(&undodir)
call EnsureDirExists(&backupdir)
call EnsureDirExists(&directory)
if s:is_windows && !s:is_cygwin | set shell=c:/windows/system32/cmd.exe | endif

if has('multi_byte')
    " Quotation dash.
    digraphs -Q 8213
    " Figure dash.
    digraphs -F 8210
    " e.g., Polish as in Grze<c-k>'s
    digraphs 's 347
    digraphs s' 347
endif

set ruler
set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
" Show number of chars/lines in visual selection.
set showcmd
" Always shown.
set laststatus=2
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
if executable('ag')
    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
endif
if has('gui_running')
    " remove toolbar
    set guioptions-=T
    " Remove left-hand toolbar in vsplit.
    " This fixes a bug where caret disappears in vsplit in 7.2.
    set guioptions-=L
    set lines=30
    let g:font = 'Bitstream\ Vera\ Sans\ Mono'
    "let g:font = 'Monospace'
    let g:fontpt = 10
    fu! SetFont()
        let &guifont=g:font.' '.g:fontpt
    endf
    fu! IncrFontPt()
        let g:fontpt = g:fontpt + 1
        call SetFont()
    endf
    fu! DecrFontPt()
        let g:fontpt = g:fontpt - 1
        call SetFont()
    endf
    call SetFont()
    " hold right click for the usual kind of menu
    set mousemodel=popup
    nmap <leader>fi :call IncrFontPt()<CR>
    nmap <leader>fd :call DecrFontPt()<CR>
endif

autocmd BufNew *
    \   if &buftype == 'quickfix' |
    \       setlocal wrap |
    \   endif
if !exists('s:filetypedetect_loaded')
    let s:filetypedetect_loaded = 1
    augroup filetypedetect
        autocmd BufRead,BufNewFile \
            \ *.text,*.txt,*.mail,*.email,*.followup,*.article,*.letter,/tmp/pico*,nn.*,snd.*,/tmp/mutt*
            \ setlocal filetype=txt
        autocmd BufRead,BufNewFile Jamfile,Jamroot,*.jam setlocal filetype=bbv2
        " .m files are objective c by default, not matlab
        autocmd BufRead,BufNewFile *.m setlocal filetype=objc
        " .proto files for google protocol buffers
        autocmd BufRead,BufNewFile *.proto setlocal filetype=proto
    augroup end
endif
if !exists('s:filetypeextras_loaded')
    let s:filetypeextras_loaded = 1
    augroup filetypeextras
        autocmd FileType pandoc,markdown runtime ftplugin/txt.vim
        autocmd FileType c,objc,objcpp runtime ftplugin/cpp.vim
        autocmd FileType perl       setlocal smartindent
        autocmd FileType make       setlocal noet sw=8 ts=8
        " Redraw rainbow parens when going back to the buffer.
        autocmd Syntax * call rainbow#load()
    augroup end
endif

fu! AutoGitCommit(filename)
    execute 'sil! !git commit -m autocommit\ '.fnameescape(fnamemodify(a:filename, ':p:t')).' '.fnameescape(a:filename)
endf
" Could be used in conjunction with set autowriteall
command! -nargs=0 -complete=file AutoGitCommitWrites
      \ autocmd BufWritePost <args> call AutoGitCommit(expand('%:t:p'))
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
  command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis | wincmd p | diffthis
endif

" Make c-u and c-w start a new change before running.
" http://vim.wikia.com/wiki/Recover_from_accidental_Ctrl-U
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
noremap Y y$
" <HOME> toggles between start of line and start of text
imap <khome> <home>
nmap <khome> <home>
fu! Home()
    let curcol = wincol()
    normal 0
    let newcol = wincol()
    if newcol == curcol | normal ^ | endif
endf
inoremap <silent> <home> <C-o>:call Home()<CR>
nnoremap <silent> <home> :call Home()<CR>
" Scroll left-right.
nnoremap <C-l> zl
nnoremap <C-h> zh
" Change cursor position in insert mode.
inoremap <C-h> <left>
inoremap <C-l> <right>
" Remap arrow keys.
nnoremap <down> :bprev<CR>
nnoremap <up> :bnext<CR>
nnoremap <left> :tabnext<CR>
nnoremap <right> :tabprev<CR>

nnoremap <leader>rr :redraw!<CR>
" Toggle.
nnoremap <leader>tn :set invnumber number?<CR>
nnoremap <leader>tp :set invpaste paste?<CR>
nnoremap <leader>tw :set invwrap wrap?<CR>
nnoremap <leader>th :set invhls hls?<CR>
" Toggle hard line wrapping at textwidth.
nnoremap <leader>tf :if &fo =~ 't' <Bar> set fo-=t fo? <Bar> else <Bar> set fo+=t fo? <Bar> endif<CR>
nnoremap <leader>tl :set invlist list?<CR>
nnoremap <leader>ts :set invspell spell?<CR>
nnoremap <leader>tw :set invwrap wrap?<CR>
" Make and quickfix."
nnoremap <leader>cc :make!<CR> <Bar> :copen<CR>
nnoremap <leader>cn :cnext<CR>
nnoremap <leader>cp :cprev<CR>
nnoremap <leader>ci :copen<CR>

" ("diff no") turn off diff mode and report the change
nnoremap <leader>dn :if &diff <Bar> diffoff <Bar> echo 'diffoff' <Bar> else <Bar> echo 'not in diff mode' <Bar> endif<CR>
" ("diff obtain") do :diffget on range and report the change:
" use "diff obtain" as that's what Vim itself uses for the non-range command: do
vnoremap <leader>do :diffget <Bar> echo 'Left >>> Right'<CR>
" ("diff put") do :diffput on range and report the change:
vnoremap <leader>dp :diffput <Bar> echo 'Left <<< Right'<CR>

" fswitch plugin macros
nnoremap <leader>fs :FSHere<CR>
nnoremap <leader>fv :FSSplitRight<CR>
" gnupg options
let g:GPGPreferArmor = 1
" svndiff plugin macros
nnoremap <silent> <leader>vn :call Svndiff("next")<CR>
nnoremap <silent> <leader>vp :call Svndiff("prev")<CR>
nnoremap <silent> <leader>vc :call Svndiff("clear")<CR>
" pyflakes-vim highlighting
augroup pyflakesfiletypedetect
    au! FileType python highlight SpellBad term=underline ctermfg=Magenta gui=undercurl guisp=Orange
augroup END
" Unite plugin
let g:unite_enable_start_insert = 1
let g:unite_source_history_yank_enable = 1
let g:unite_source_rec_max_cache_files = 5000
let g:unite_data_directory = '~/.vim/.cache/unite'
call EnsureDirExists(g:unite_data_directory)
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
    fu! s:indent_set_console_colors()
        hi IndentGuidesOdd ctermbg=235
        hi IndentGuidesEven ctermbg=236
    endf
    autocmd VimEnter,Colorscheme * call s:indent_set_console_colors()
endif
" vim-startify
let g:startify_list_order = ['bookmarks', 'files', 'dir', 'sessions']
let g:startify_bookmarks = ['~/work/gavinbeatty/configs/common/vimrc.vim']
let g:ycm_key_list_select_completion=['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion=['<C-p>', '<Up>']
let g:ycm_filetype_blacklist={'unite': 1}
" rainbow operators"
let g:rainbow_active = 1
let g:rainbow_operators = 1

source ~/.vimrc.unicode.vim
source ~/.vimrc.post.vim
