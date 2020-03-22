" vi: set fenc=utf-8 sw=2 ts=2:
set nocompatible
set encoding=utf-8
scriptencoding utf-8
let s:is_purewin = has('win32') || has('win64')
let s:is_fakewin = has('win32unix')
let s:is_windows = s:is_purewin || s:is_fakewin
if has('nvim')
  fu! s:StdPath(p)
    return stdpath(a:p)
  endf
else
  if s:is_purewin
    let s:vimfiles = expand('~/vimfiles')
  else
    let s:vimfiles = expand('~/.vim')
  endif
  fu! s:StdPath(p)
    if a:p == 'config' || a:p == 'data' || a:p == 'cache'
      return s:vimfiles
    else
      throw a:p.' is unsupported in vim emulation of stdpath()'
    endif
  endf
endif
call execute('source '.fnameescape(s:StdPath('config').'/pre.vim'),'silent!')
if !exists('g:machine') | let g:machine = 'unknown' | endif
if !exists('g:cpp_expandtab') | let g:cpp_expandtab = 1 | endif
if !exists('g:cpp_textwidth') | let g:cpp_textwidth = 100 | endif
if !exists('mapleader') | let mapleader = ',' | endif
if !exists('g:mapleader') | let g:mapleader = ',' | endif
" `vim --cmd 'let g:none=1' ...` to disable all plugins at startup, including dein.
if !exists('g:none') | let g:none = 0 | endif
" `vim --cmd 'let g:min=1' ...` to disable many plugins at startup.
if !exists('g:min') | let g:min = g:none | endif
" `vim --cmd 'let g:justdein=1' ...` to disable all plugins at startup, except dein.
if !exists('g:justdein') | let g:justdein = 0 | endif

" Need a ctags rethink.
"let &tags = getcwd().'/tags,'
"set nocscopeverbose
"exec 'cscope add '.fnameescape(getcwd().'/cscope.out')
"set cscopeverbose
"for j in ["Jamroot.jam", "Jamroot", "project-root.jam"]
"  if findfile(j, ",") == j
"    set makeprg=bj.bash
"  endif
"endfor

" The below 2 filetype lines fix return code of vim on Mac OS X, when using pathogen.
" http://andrewho.co.uk/weblog/vim-pathogen-with-mutt-and-git
" I leave them here, even though I now use dein.
filetype on
filetype off
" Find a way to stop using vimproc to get rid of this logic.
if executable('gmake')
  let g:make = 'gmake'
elseif executable('C:/msys64/mingw64/bin/mingw32-make.exe')
  let g:make = 'C:/msys64/mingw64/bin/mingw32-make.exe'
elseif executable('C:/msys64/mingw32/bin/mingw32-make.exe')
  let g:make = 'C:/msys64/mingw32/bin/mingw32-make.exe'
else
  let g:make = 'make'
endif
let s:deinadding = 0
let s:deinif = 0
let s:minif = 0
let s:deindir = s:StdPath('config').'/dein'
let s:deinrepodir = s:deindir.'/repos/github.com/Shougo/dein.vim'
if !filereadable(s:deinrepodir.'/autoload/dein.vim')
  autocmd VimEnter * echomsg 'git clone -b 1.5 --single-branch https://github.com/Shougo/dein.vim '.shellescape(s:deinrepodir).''
elseif !g:none
  let &rtp.=','.fnameescape(s:deinrepodir)
  if dein#load_state(s:deindir)
    let s:deinadding = 1
    call dein#begin(s:deindir)
    call dein#add(s:deinrepodir, {'rev': '1.5'})
    if g:justdein
      let s:deinif = 0
      let s:minif = 0
    elseif g:min
      let s:deinif = 1
      let s:minif = 0
    else
      let s:deinif = 1
      let s:minif = 1
    endif
    " Dependencies
    if !s:is_windows
      call dein#add('Shougo/vimproc', {'build': g:make, 'if': s:deinif})
      call dein#add('Shougo/vimshell', {'if': s:deinif})
    endif
    call dein#add('def-lkb/vimbufsync', {'if': s:deinif})
    call dein#add('tpope/vim-repeat', {'if': s:deinif})
    " Syntax
    call dein#add('jstrater/mpvim', {'on_ft': ['portfile'], 'if': s:deinif})
    call dein#add('grisumbras/vim-b2', {'on_ft': ['bbv2'], 'if': s:deinif})
    call dein#add('chikamichi/mediawiki.vim', {'on_ft': ['mediawiki'], 'if': s:deinif})
    call dein#add('tpope/vim-markdown', {'on_ft': ['markdown'], 'if': s:deinif})
    call dein#add('vim-jp/cpp-vim', {'on_ft': ['cpp'], 'if': s:deinif})
    call dein#add('lifepillar/vim-solarized8', {'if': s:deinif})
    call dein#add('vim-airline/vim-airline', {'if': s:minif})
    call dein#add('vim-airline/vim-airline-themes', {'if': s:minif})
    call dein#add('tpope/vim-git', {'if': s:minif})
    call dein#add('rhysd/committia.vim', {'if': s:minif})
    " Math
    call dein#add('gu-fan/mathematic.vim', {'if': s:deinif})
    call dein#add('gavinbeatty/vmath.vim', {'if': s:deinif})
    " Programming
    let g:indentLine_setColors = 0
    let g:indentLine_char_list = ['|', '¦', '┆', '┊']
    call dein#add('Yggdroot/indentLine', {'if': s:deinif})
    call dein#add('bogado/file-line', {'if': s:deinif})
    call dein#add('vim-scripts/FSwitch', {'if': s:deinif})
    call dein#add('MarcWeber/vim-addon-local-vimrc', {'if': s:deinif})
    call dein#add('Shougo/denite.nvim', {'if': s:minif})
    call dein#add('chazy/cscope_maps', {'if': s:deinif})
    call dein#add('tpope/vim-dispatch', {'if': s:deinif})
    call dein#add('kana/vim-operator-user', {'if': s:minif})
    call dein#add('tpope/vim-endwise', {'if': s:minif})
    call dein#add('scrooloose/syntastic', {'if': s:minif})
    call dein#add('scrooloose/nerdcommenter', {'if': s:minif})
    call dein#add('tpope/vim-sleuth', {'if': s:minif})
    call dein#add('gavinbeatty/rainbow_parentheses.vim', {'rev': 'bugfix/toggle-all-chevrons', 'if': s:minif})
    " OCaml
    "if !g:min && executable('opam')
    "  let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
    "  execute 'set rtp+='.g:opamshare.'/merlin/vim'
    "  execute 'helptags '.g:opamshare.'/merlin/vim/doc'
    "endif
    " C++
    "if !g:min
    "  if has('python3') && execute(':python3 import vim', 'silent!')
    "    set pyx=3
    "  elseif has('python') && execute(':python import vim', 'silent!')
    "    set pyx=2
    "  endif
    "endif
    "if !s:is_windows && (has('python') || has('python3'))
    "  call dein#add('lyuts/vim-rtags', {'on_ft': ['c', 'cpp'], 'if': s:minif})
    "endif
    "if has('python') || has('python3')
    "  call dein#add('bbchung/clighter8', {'on_ft': ['c', 'cpp'], 'if': s:minif})
    "endif
    let g:clang_format#detect_style_file = 1
    call dein#add('rhysd/vim-clang-format', {'on_ft': ['c', 'cpp'], 'on_map': [['n', '<Plug>(operator-clang-format)']], 'if': s:minif})
    " Python
    call dein#add('nvie/vim-flake8', {'on_ft': ['python'], 'if': s:minif})
    "call dein#add('ehamberg/vim-cute-python', {'on_ft': ['python'], 'if': s:minif})
    " Text
    call dein#add('elzr/vim-json', {'on_ft': ['json'], 'if': s:minif})
    call dein#add('kana/vim-fakeclip', {'if': s:minif})
    call dein#add('godlygeek/tabular', {'if': s:minif})
    call dein#add('tpope/vim-surround', {'if': s:minif})
    call dein#add('Lokaltog/vim-easymotion', {'if': s:minif})
    call dein#add('zirrostig/vim-schlepp', {'if': s:minif})
    call dein#add('gavinbeatty/hudigraphs_utf8.vim', {'if': s:minif})
    call dein#add('gavinbeatty/hlnext.vim', {'if': s:minif})
    let wiki = {}
    let wiki.path = '~/vimwiki/'
    let wiki.syntax = 'markdown'
    let wiki.ext = '.mkd'
    let wiki.nested_syntaxes = {'python': 'python', 'cpp': 'cpp', 'csharp': 'cs'}
    let g:vimwiki_list = [wiki]
    let g:vimwiki_hl_headers = 1
    let g:vimwiki_hl_cb_checked = 1
    call dein#add('vimwiki/vimwiki', {'if': s:minif})
    " Files
    call dein#add('mhinz/vim-startify', {'if': s:minif})
    call dein#add('jamessan/vim-gnupg', {'if': s:minif})
    call dein#add('gmarik/sudo-gui.vim', {'if': s:minif})
    call dein#add('regedarek/vim-bufexplorer', {'if': s:minif})
    " Optional
    call dein#add('thinca/vim-fontzoom', {
          \ 'if': s:minif && has('gui_running'),
          \ 'on_map': [['n', '<Plug>(fontzoom-larger)'], ['n', '<Plug>(fontzoom-smaller)']],
          \ })
    "call dein#add('vim-scripts/Conque-GDB', {'on_cmd': ['ConqueTerm', 'ConqueGdb'], 'if': s:minif})
    call dein#add('thinca/vim-quickrun', {'on_map': '<Plug>(quickrun)', 'if': s:minif})
    call dein#end()
    "call dein#save_state()  " Breaks colorscheme on second run of vim.
  endif
endif

syntax enable
highlight DiffAdd ctermfg=0 ctermbg=2 guibg='green'
highlight DiffDelete ctermfg=0 ctermbg=1 guibg='red'
highlight DiffChange ctermfg=0 ctermbg=3 guibg='yellow'
if &term =~ '256'
  set t_Co=256
  set termguicolors
  set t_8f=[38;2;%lu;%lu;%lum
  set t_8b=[48;2;%lu;%lu;%lum
endif
set background=dark
" See :h filetype-overview
filetype plugin indent on
if s:is_purewin
  colorscheme slate
else
  try
    silent! colorscheme solarized8_flat
  catch /.*/
    colorscheme slate
  endtry
endif
set nonumber
set expandtab
set tabstop=4
set shiftwidth=4
set textwidth=90
call matchadd('ColorColumn', '\%' . &textwidth . 'v', 100)
set matchpairs+=<:>
set noshowmatch
set completeopt=menuone,longest
set listchars=nbsp:~,tab:»\ ,precedes:←,extends:→,trail:·
set list
" Don't automatically format text as it's typed.
set formatoptions-=t
if v:version > 703 || v:version == 703 && has("patch541")
  " Delete comment character when joining commented lines
  set formatoptions+=j
endif
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
" Turn off audio bells (by enabling visual) and disable visual effect.
set noerrorbells visualbell t_vb=
" Sync with OS clipboard outside tmux.
if exists('$TMUX') | set clipboard=
else | set clipboard=unnamed
endif
if exists('+autochdir') | set autochdir
else | au BufEnter * sil! lcd fnameescape(expand('%:p:h'))
endif
if s:is_windows && has('+shellslash') | set shellslash | endif

fu! s:EnsureDirExists(path)
  sil! call mkdir(expand(a:path), 'p')
endf
if !has('nvim')
  if exists('+undofile') | set undofile | let &undodir=s:StdPath('data').'/undo' | endif
  let &backupdir=s:StdPath('data').'/backup'
  let &directory=s:StdPath('data').'/swap'
  call s:EnsureDirExists(&undodir)
  call s:EnsureDirExists(&backupdir)
  call s:EnsureDirExists(&directory)
  if s:is_purewin | let &shell=$SystemRoot.'/system32/cmd.exe' | endif
endif

if has('multi_byte')
  " Quotation dash.
  digraphs -Q 8213
  " Figure dash.
  digraphs -F 8210
  " e.g., Polish as in Grze<c-k>'s
  digraphs 's 347
  digraphs s' 347
endif

set title titlestring=
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
  fu! s:SetFont()
    let &guifont=g:font.' '.g:fontpt
  endf
  fu! s:IncrFontPt()
    let g:fontpt = g:fontpt + 1
    call s:SetFont()
  endf
  fu! s:DecrFontPt()
    let g:fontpt = g:fontpt - 1
    call s:SetFont()
  endf
  call s:SetFont()
  " hold right click for the usual kind of menu
  set mousemodel=popup
  nnoremap <leader>fi :call s:IncrFontPt()<CR>
  nnoremap <leader>fd :call s:DecrFontPt()<CR>
endif

if !exists('s:OneBigAugroup')
  let s:OneBigAugroup = 1
  augroup OneBigAugroup
      au!
      au SwapExists * let v:swapchoice = 'o'
      au SwapExists * echomsg ErrorMsg
      au SwapExists * echo 'Duplicate edit session (readonly)'
      au SwapExists * echohl None
      au SwapExists * sleep 2
  augroup end
endif
au BufNew * if &buftype == 'quickfix' | setlocal wrap | endif
if !exists('s:filetypedetect_loaded')
  let s:filetypedetect_loaded = 1
  augroup filetypedetect
    au BufRead,BufNewFile \
      \ *.text,*.txt,*.mail,*.email,*.followup,*.article,*.letter,/tmp/pico*,nn.*,snd.*,/tmp/mutt*
      \ setlocal filetype=txt
    au BufRead,BufNewFile CMake*.txt setlocal filetype=cmake
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
if executable('opam') && !exists('s:ocamlextras_loaded')
  let s:ocamlextras_loaded = 1
  augroup ocamlextras
    au FileType ocaml ++once exec 'source '.g:opamshare.'/ocp-indent/vim/indent/ocaml.vim'
    au FileType ocaml ++once exec 'set rtp+='.g:opamshare.'/merlin/vim'
  augroup end
endif

fu! s:AutoGitCommit(filename)
  execute 'sil! !git commit -m autocommit\ '.fnameescape(fnamemodify(a:filename, ':p:t')).' '.fnameescape(a:filename)
endf
" Could be used in conjunction with set autowriteall
command! -nargs=0 -complete=file AutoGitCommitWrites
      \ au BufWritePost <args> call s:AutoGitCommit(expand('%:t:p'))
command! WUtf8 setlocal fenc=utf-8 nobomb
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

nnoremap <leader>a= :Tabularize /=<CR>
vnoremap <leader>a= :Tabularize /=<CR>
nnoremap <leader>a: :Tabularize /:<CR>
vnoremap <leader>a: :Tabularize /:<CR>

nnoremap <leader>il :IndentLinesToggle<CR>

nnoremap <leader>rr :redraw!<CR>
" Toggle.
nnoremap <leader>tn :set invnumber number?<CR>
nnoremap <leader>tp :set invpaste paste?<CR>
nnoremap <leader>tw :set invwrap wrap?<CR>
nnoremap <leader>th :call HLNextOff() <Bar> set invhlsearch hlsearch?<CR>
" Toggle hard line wrapping at textwidth.
nnoremap <leader>tf :if &fo =~ 't' <Bar> set fo-=t fo? <Bar> else <Bar> set fo+=t fo? <Bar> endif<CR>
nnoremap <leader>tl :set invlist list?<CR>
nnoremap <leader>ts :set invspell spell?<CR>
if exists(':RainbowParentheses')
  nnoremap <silent> <leader>tr :RainbowParenthesesToggleAll <Bar> RainbowParenthesesActivate<CR>
endif
nnoremap <leader>sus :set spelllang=en_us spelllang?<CR>
nnoremap <leader>sgb :set spelllang=en_gb spelllang?<CR>
nnoremap <leader>tw :set invwrap wrap?<CR>
" Make and quickfix.
nnoremap <leader>bb :make!<CR> <Bar> :copen<CR>
nnoremap <leader>bn :cnext<CR>
nnoremap <leader>bp :cprev<CR>
nnoremap <leader>bi :copen<CR>

nnoremap <leader>st :Startify<cr>

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

"let g:denite_enable_start_insert = 1
let g:denite_source_history_yank_enable = 1
let g:denite_source_rec_max_cache_files = 5000
let g:denite_data_directory = s:StdPath('data').'/denite'
call s:EnsureDirExists(g:denite_data_directory)
if exists('*denite#custom#profile')
  call denite#custom#profile('files', 'context.smartcase', 1)
endif
if executable('ag')
  set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
  set grepformat=%f:%l:%c:%m
  let g:denite_source_grep_command = 'ag'
  let g:denite_source_grep_default_opts = '--nogroup --column --smart-case --nocolor --follow -C4'
  let g:denite_source_grep_recursive_opt = ''
elseif executable('ack')
  set grepprg=ack\ --noheading\ -H\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
  set grepformat=%f:%l:%c:%m
  let g:denite_source_grep_command = 'ack'
  let g:denite_source_grep_default_opts = '--noheading -H --nogroup --column --smart-case --nocolor --follow -a -C4'
  let g:denite_source_grep_recursive_opt = ''
endif
if !g:min
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

if !g:min && !s:is_windows
  let g:OmniSharp_selector_ui = 'denite'
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

let g:airline_extensions = []
let g:airline_theme = 'solarized'
let g:airline_solarized_bg = 'dark'

let g:startify_list_order = ['bookmarks', 'files', 'dir', 'sessions']
if s:is_fakewin
  let s:homedir = system('cygpath -u "$USERPROFILE" | tr -d \\n')
  let g:startify_bookmarks = [
    \ {'w': s:homedir.'/work'},
    \ {'c': s:homedir.'/work/gavinbeatty/configs/common/vimrc.vim'},
    \ ]
else
  let g:startify_bookmarks = [
    \ {'w': expand('~/work')},
    \ {'c': expand('~/work/gavinbeatty/configs/common/vimrc.vim')},
    \ ]
endif

let g:syntastic_enable_highlighting = 1
"let g:syntastic_ignore_files = ['^/usr/include/', '/x_boost.*/', '^/opt/rh/devtoolset[^/]*/']
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']

nnoremap <leader>km :set keymap=mathematic<CR>
nnoremap <leader>kn :set keymap=<CR>
let s:mathematic_vim_dir = fnameescape(s:deindir.'/repos/github.com/gu-fan/mathematic.vim/keymap/mathematic.vim')
nnoremap <leader>ks :exec 'sp '.s:mathematic_vim_dir<CR>
nnoremap <leader>kv :exec 'vs '.s:mathematic_vim_dir<CR>

call execute('source '.fnameescape(s:StdPath('config').'/post.vim'),'silent!')
