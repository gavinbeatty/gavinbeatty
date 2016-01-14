set nocompatible
let s:is_windows = has('win32') || has('win64')
let s:is_cygwin = has('win32unix')
let s:is_mac = !s:is_windows && !s:is_cygwin
      \ && (has('mac') || has('macunix') || has('gui_macvim') ||
      \   (!executable('xdg-open') && system('uname') =~? '^darwin'))
let s:is_macvim = has('gui_macvim')
source ~/.vimrc.pre.vim
if !exists('g:machine') | let g:machine = 'unknown' | endif
if !exists('g:cpp_expandtab') | let g:cpp_expandtab = 1 | endif
if !exists('g:cpp_textwidth') | let g:cpp_textwidth = 100 | endif
if !exists('mapleader') | let mapleader = ',' | endif
if !exists('g:mapleader') | let g:mapleader = ',' | endif
if !exists('g:none') | let g:none = 0 | endif
if !exists('g:min') | let g:min = 0 | endif

let &tags = getcwd().'/tags,'
set nocscopeverbose
exec 'cscope add '.fnameescape(getcwd().'/cscope.out')
set cscopeverbose
for j in ["Jamroot.jam", "Jamroot", "project-root.jam"]
  if findfile(j, ",") == j
    set makeprg=bj.bash
  endif
endfor

" The below 2 filetype lines fix return code of vim on Mac OS X, when using pathogen.
" http://andrewho.co.uk/weblog/vim-pathogen-with-mutt-and-git
" I leave them here, even though I now use neobundle.
filetype on
filetype off
if s:is_windows | set rtp+=~/.vim | endif
let g:make = 'gmake'
if system('uname -o') =~ '^GNU/' | let g:make = 'make' | endif
if !g:none
set rtp+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle'))
NeoBundleFetch 'Shougo/neobundle.vim'
" Dependencies
NeoBundle 'Shougo/vimproc', {'build': {
      \ 'windows': g:make . ' -f make_mingw32.mak',
      \ 'cygwin': g:make . ' -f make_cygwin.mak',
      \ 'mac': g:make . ' -f make_mac.mak',
      \ 'unix': g:make . ' -f make_unix.mak',
      \ }}
NeoBundleLazy 'Shougo/vimshell', {'autoload': {
      \   'commands': [{'name': 'VimShell',
      \                 'complete': 'customlist,vimshell#complete'},
      \                'VimShellExecute', 'VimShellInteractive',
      \                'VimShellTerminal', 'VimShellPop'],
      \   'mappings': ['<Plug>(vimshell_switch)']
      \ }}
NeoBundle 'def-lkb/vimbufsync'
NeoBundle 'tpope/vim-repeat'
" Syntax
NeoBundleLazy 'jstrater/mpvim', {'autoload': {'filetypes': 'portfile'}}
NeoBundleLazy 'vim-scripts/Boost-Build-v2-BBv2-syntax', {'autoload': {'filetypes': 'bbv2'}}
NeoBundleLazy 'chikamichi/mediawiki.vim', {'autoload': {'filetypes': 'mediawiki'}}
NeoBundleLazy 'tpope/vim-markdown', {'autoload': {'filetypes': 'markdown'}}
NeoBundleLazy 'vim-jp/cpp-vim', {'autoload': {'filetypes': 'cpp'}}
NeoBundleLazy 'OmniSharp/omnisharp-vim', {'build': {'unix': 'cd server && xbuild'}, 'autoload': {'filetypes': 'cs'}}
NeoBundle 'altercation/vim-colors-solarized'
" The below allows (via `vim --cmd 'let g:min=1'` etc.) disabling many plugins at startup.
if !g:min
NeoBundle 'bling/vim-airline'
NeoBundle 'tpope/vim-git'
endif
" Math
NeoBundle 'vim-scripts/mathematic.vim'
" Programming
let g:indentLine_char = '│'
if !g:min
let g:indentLine_color_term = 239
endif
NeoBundle 'Yggdroot/indentLine'
NeoBundle 'bogado/file-line'
NeoBundle 'vim-scripts/FSwitch'
NeoBundle 'MarcWeber/vim-addon-local-vimrc'
if !g:min
NeoBundleLazy 'Shougo/unite.vim', {'autoload': {
      \ 'commands': [{'name': 'Unite',
      \                'complete': 'customlist,unite#complete_source'
      \              }, 'UniteWithCursorWord', 'UniteWithInput'
      \              ]}}
endif
NeoBundle 'chazy/cscope_maps'
NeoBundle 'tpope/vim-dispatch'
if !g:min
NeoBundle 'tpope/vim-endwise'
NeoBundle 'scrooloose/syntastic'
NeoBundle 'scrooloose/nerdcommenter'
NeoBundle 'tpope/vim-sleuth'
NeoBundle 'vim-scripts/Rainbow-Parentheses-Improved-and2'
" OCaml
NeoBundle 'the-lambda-church/merlin', {'autoload': {'filetypes': 'ocaml'}, 'rtp': 'vim/merlin'}
NeoBundle 'OCamlPro/ocp-indent', {'autoload': {'filetypes': 'ocaml'}, 'script_type': 'plugin', 'rtp': 'tools'}
" Haskell
NeoBundle 'feuerbach/vim-hs-module-name'
NeoBundleLazy 'vim-scripts/Superior-Haskell-Interaction-Mode-SHIM', {'autoload': {'filetypes': 'haskell'}}
NeoBundleLazy 'Twinside/vim-haskellConceal', {'autoload': {'filetypes': 'haskell'}}
NeoBundleLazy 'eagletmt/ghcmod-vim', {'autoload': {'filetypes': 'haskell'}}
NeoBundleLazy 'ujihisa/neco-ghc', {'autoload': {'filetypes': 'haskell'}}
" C++
if has('python')
python import vim ; vim.vars['pyver'] = '.'.join(str(x) for x in sys.version_info[0:2])
let g:macportspypath = fnameescape('/opt/local/Library/Frameworks/Python.framework/Versions/'.pyver.'/bin:'.$PATH)
NeoBundle 'Valloric/YouCompleteMe', {
  \ 'vim_version':'7.3.584',
  \ 'build':{
    \ 'mac' : 'env PATH="'.g:macportspypath.'" ./install.sh --clang-completer --system-libclang',
    \ 'unix': './install.sh --clang-completer --system-libclang',
  \ },
  \ }
NeoBundle 'lyuts/vim-rtags'
endif
" Python
NeoBundleLazy 'nvie/vim-flake8', {'autoload': {'filetypes': 'python'}}
NeoBundleLazy 'ehamberg/vim-cute-python', {'autoload': {'filetypes': 'python'}}
" Text
NeoBundleLazy 'elzr/vim-json', {'autoload': {'filetypes': 'json'}}
NeoBundle 'kana/vim-fakeclip'
NeoBundle 'godlygeek/tabular'
NeoBundle 'tpope/vim-surround'
NeoBundle 'Lokaltog/vim-easymotion'
" Files
NeoBundle 'mhinz/vim-startify'
NeoBundle 'jamessan/vim-gnupg'
NeoBundle 'gmarik/sudo-gui.vim'
NeoBundle 'regedarek/vim-bufexplorer'
" Optional
NeoBundleLazy 'thinca/vim-fontzoom', {
      \ 'gui': 1,
      \ 'autoload': {
      \  'mappings': [
      \   ['n', '<Plug>(fontzoom-larger)'], ['n', '<Plug>(fontzoom-smaller)']
      \  ],
      \ }}
NeoBundleLazy 'vim-scripts/Conque-GDB', {'autoload': {'commands': ['ConqueTerm', 'ConqueGdb']}}
NeoBundleLazy 'thinca/vim-quickrun', { 'autoload': {
      \ 'mappings': [['nxo', '<Plug>(quickrun)']],
      \ }}
endif
call neobundle#end()
NeoBundleCheck
endif

syntax enable
highlight DiffAdd ctermfg=0 ctermbg=2 guibg='green'
highlight DiffDelete ctermfg=0 ctermbg=1 guibg='red'
highlight DiffChange ctermfg=0 ctermbg=3 guibg='yellow'
if &term =~ '256' | let g:solarized_termcolors=256 | set t_Co=256 | endif
set background=dark
" See :h filetype-overview
filetype plugin indent on
if !g:none
    colorscheme solarized
endif
if !exists('g:colors_name') || g:colors_name != 'solarized'
    colorscheme slate
endif
set nonumber
set expandtab
set tabstop=4
set shiftwidth=4
set textwidth=90
set matchpairs+=<:>
set noshowmatch
set completeopt=menuone,longest
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
set splitbelow
set splitright
" Minimum number of lines the search result may be from the top/bottom.
set scrolloff=10
set showmode
" Path/file matching in command mode like bash's.
set wildmode=list:longest,list:full
set wildchar=<TAB>
set wildignore+=*/.git*,*/.hg/*,*/.svn/*,*/.bzr/*,*/.idea/*,*/.DS_Store
" Show a tab through menu.
set wildmenu
set printoptions=paper:a4
set ttyfast
set novisualbell
set noerrorbells
" Workaround to get rid of audible bell, that doesn't actually enable visual bell.
if s:is_macvim | set visualbell | endif
" Sync with OS clipboard outside tmux.
if exists('$TMUX') | set clipboard=
else | set clipboard=unnamed
endif
if exists('+autochdir') | set autochdir
else | au BufEnter * sil! lcd fnameescape(expand('%:p:h'))
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
" My original: set statusline=%<%f\ %=\:\b%n%y%m%r%w\ %l,%c%V\ %P
set shortmess+=r
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
    nnoremap <leader>fi :call IncrFontPt()<CR>
    nnoremap <leader>fd :call DecrFontPt()<CR>
endif

au BufNew * if &buftype == 'quickfix' | setlocal wrap | endif
if !exists('s:filetypedetect_loaded')
    let s:filetypedetect_loaded = 1
    augroup filetypedetect
        au BufRead,BufNewFile \
            \ *.text,*.txt,*.mail,*.email,*.followup,*.article,*.letter,/tmp/pico*,nn.*,snd.*,/tmp/mutt*
            \ setlocal filetype=txt
        au BufRead,BufNewFile Jamfile,Jamroot,*.jam setlocal filetype=bbv2
        " .m files are objective c by default, not matlab
        au BufRead,BufNewFile *.m setlocal filetype=objc
        " .proto files for google protocol buffers
        au BufRead,BufNewFile *.proto setlocal filetype=proto
    augroup end
endif
if !exists('s:filetypeextras_loaded')
    let s:filetypeextras_loaded = 1
    augroup filetypeextras
        au FileType pandoc,markdown runtime ftplugin/txt.vim
        au FileType c,objc,objcpp runtime ftplugin/cpp.vim
        au FileType cs runtime ftplugin/cs.vim
        au FileType perl setlocal smartindent
        au FileType make setlocal noet sw=8 ts=8
        au! FileType python highlight SpellBad term=underline ctermfg=Magenta gui=undercurl guisp=Orange
    augroup end
endif
if exists(':Rainbow') && !exists('s:filetypeextras_rainbow_loaded')
    let s:filetypeextras_rainbow_loaded = 1
    augroup filetypeextras_rainbow
        " Redraw rainbow parens when going back to the buffer.
        au Syntax * call rainbow#load()
    augroup end
endif

fu! AutoGitCommit(filename)
    execute 'sil! !git commit -m autocommit\ '.fnameescape(fnamemodify(a:filename, ':p:t')).' '.fnameescape(a:filename)
endf
" Could be used in conjunction with set autowriteall
command! -nargs=0 -complete=file AutoGitCommitWrites
      \ au BufWritePost <args> call AutoGitCommit(expand('%:t:p'))
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
fu! Home()
    let curcol = wincol()
    normal 0
    let newcol = wincol()
    if newcol == curcol
        normal ^
    endif
endf
" <HOME> toggles between start of line and start of text
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

nnoremap <leader>il :IndentLinesToggle<CR>

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
nnoremap <leader>sus :set spelllang=en_us spelllang?<CR>
nnoremap <leader>sgb :set spelllang=en_gb spelllang?<CR>
nnoremap <leader>tw :set invwrap wrap?<CR>
" Make and quickfix.
nnoremap <leader>bb :make!<CR> <Bar> :copen<CR>
nnoremap <leader>bn :cnext<CR>
nnoremap <leader>bp :cprev<CR>
nnoremap <leader>bi :copen<CR>

nnoremap <leader>st :Startify<cr>

nnoremap <leader>bc :YcmDiags<cr>
nnoremap <leader>jd :YcmCompleter GoToDefinitionElseDeclaration<cr>
nnoremap <leader>jD :YcmCompleter GoToDeclaration<cr>

" ("diff no") turn off diff mode and report the change
nnoremap <leader>dn :if &diff <Bar> diffoff <Bar> echo 'diffoff' <Bar> else <Bar> echo 'not in diff mode' <Bar> endif<CR>
" ("diff obtain") do :diffget on range and report the change:
" use "diff obtain" as that's what Vim itself uses for the non-range command: do
vnoremap <leader>do :diffget <Bar> echo 'Left >>> Right'<CR>
" ("diff put") do :diffput on range and report the change:
vnoremap <leader>dp :diffput <Bar> echo 'Left <<< Right'<CR>

nnoremap <leader>fs :FSHere<CR>
nnoremap <leader>fv :FSSplitRight<CR>
nnoremap <leader>fh :FSSplitAbove<CR>
nnoremap <silent> <leader>vn :call Svndiff("next")<CR>
nnoremap <silent> <leader>vp :call Svndiff("prev")<CR>
nnoremap <silent> <leader>vc :call Svndiff("clear")<CR>
let g:GPGPreferArmor = 1
let g:delimitMate_matchpairs = "(:),[:],{:}"

"let g:unite_enable_start_insert = 1
let g:unite_source_history_yank_enable = 1
let g:unite_source_rec_max_cache_files = 5000
let g:unite_data_directory = '~/.vim/.cache/unite'
call EnsureDirExists(g:unite_data_directory)
if !g:none && !g:min
  call unite#custom#profile('files', 'context.smartcase', 1)
endif
if executable('ag')
    set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
    let g:unite_source_grep_command = 'ag'
    let g:unite_source_grep_default_opts = '--nogroup --column --smart-case --nocolor --follow -C4'
    let g:unite_source_grep_recursive_opt = ''
elseif executable('ack')
    set grepprg=ack\ --noheading\ -H\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
    set grepformat=%f:%l:%c:%m
    let g:unite_source_grep_command = 'ack'
    let g:unite_source_grep_default_opts = '--noheading -H --nogroup --column --smart-case --nocolor --follow -a -C4'
    let g:unite_source_grep_recursive_opt = ''
endif
if !g:none && !g:min
if s:is_windows
    nnoremap <silent> <leader><space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec buffer file_mru bookmark<cr><c-u>
    nnoremap <silent> <leader>uf :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec<cr><c-u>
else
    nnoremap <silent> <leader><space> :<C-u>Unite -toggle -auto-resize -buffer-name=mixed file_rec/async buffer file_mru bookmark<cr><c-u>
    nnoremap <silent> <leader>uf :<C-u>Unite -toggle -auto-resize -buffer-name=files file_rec/async<cr><c-u>
endif
nnoremap <silent> <leader>uy :<C-u>Unite -buffer-name=yanks history/yank<cr>
nnoremap <silent> <leader>ul :<C-u>Unite -auto-resize -buffer-name=line line<cr>
nnoremap <silent> <leader>ub :<C-u>Unite -auto-resize -buffer-name=buffers buffer<cr>
nnoremap <silent> <leader>u/ :<C-u>Unite -no-quit -buffer-name=search grep:.<cr>
nnoremap <silent> <leader>um :<C-u>Unite -auto-resize -buffer-name=mappings mapping<cr>
nnoremap <silent> <leader>us :<C-u>Unite -quick-match buffer<cr>
endif

nnoremap <silent> <leader>gs :Gstatus<CR>
nnoremap <silent> <leader>gd :Gdiff<CR>
nnoremap <silent> <leader>gc :Gcommit<CR>
nnoremap <silent> <leader>gb :Gblame<CR>
nnoremap <silent> <leader>gl :Glog<CR>
nnoremap <silent> <leader>gp :Git push<CR>
nnoremap <silent> <leader>gw :Gwrite<CR>
nnoremap <silent> <leader>gr :Gremove<CR>
au BufReadPost fugitive://* set bufhidden=delete"

if !g:none && !g:min
let g:OmniSharp_selector_ui = 'unite'
endif

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

let g:startify_list_order = ['bookmarks', 'files', 'dir', 'sessions']
let g:startify_bookmarks = ['~/work/gavinbeatty/configs/common/vimrc.vim']

let g:ycm_confirm_extra_conf = 0
let g:ycm_filetype_whitelist = {
  \ 'c': 1, 'cpp': 1, 'objcpp': 1
  \ }

let g:syntastic_enable_highlighting = 1
"let g:syntastic_ignore_files = ['^/usr/include/', '/x_boost.*/', '^/opt/rh/devtoolset[^/]*/']
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']

let g:rainbow_active = 1
let g:rainbow_operators = 1

nnoremap <leader>km :set keymap=mathematic<CR>
nnoremap <leader>kn :set keymap=<CR>
nnoremap <leader>ks :sp ~/.vim/bundle/mathematic.vim/keymap/mathematic.vim<CR>
nnoremap <leader>kv :vs ~/.vim/bundle/mathematic.vim/keymap/mathematic.vim<CR>

source ~/.vimrc.post.vim
