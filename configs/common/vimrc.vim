" DON'T keep compatibility with vi
set nocompatible
source ~/.vimrc.pre.vim
if !exists('g:machine')
    let g:machine = 'unknown'
endif
if !exists('g:cpp_expandtab')
    let g:cpp_expandtab = 1
endif
if !exists('g:cpp_textwidth')
    let g:cpp_textwidth = 100
endif

function! Gav_fnameescape(name)
    if exists('*fnameescape')
        return fnameescape(a:name)
    endif
    return a:name
endfunction
function! Gav_abspath(name)
    if exists('*fnamemodify')
        return fnamemodify(a:name, ':p')
    endif
    return getcwd().'/'.a:name
endfunction
function! Gav_leaf(path)
    if exists('*fnamemodify')
        return fnamemodify(a:path, ':p:t')
    endif
    echoerr 'fnamemodify required'
    return a:path
endfunction

if filereadable(getcwd().'/tags')
    exec 'set tags+='.Gav_fnameescape(getcwd()).'/tags'
endif
if filereadable(getcwd().'/cscope.out')
    exec 'cscope add '.Gav_fnameescape(getcwd()).'/cscope.out'
endif
set listchars=
if has('multi_byte')
    if matchend(v:lang, '[Uu][Tt][Ff][-_]\?8')
        set encoding=utf-8
        set nobomb
        let g:trail = '␣'
        set listchars=nbsp:·,tab:»\ ,precedes:<,extends:>
        exec 'set listchars+=trail:' . g:trail
        if has('autocmd')
            autocmd InsertEnter * exec 'set listchars-=trail:' . g:trail
            autocmd InsertLeave * exec 'set listchars+=trail:' . g:trail
        endif
    endif
endif
if &listchars == ''
    set listchars=nbsp:~,tab:>\ ,precedes:<,extends:>
endif
" The below 2 filetype lines fix return code of vim on Mac OS X, when using
" pathogen.
" http://andrewho.co.uk/weblog/vim-pathogen-with-mutt-and-git
filetype on
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'altercation/vim-colors-solarized'
Bundle 'dag/vim2hs'
Bundle 'scrooloose/syntastic'
Bundle 'ujihisa/neco-ghc'
Bundle 'eagletmt/ghcmod-vim'
Bundle 'godlygeek/tabular'
Bundle 'wincent/Command-T'
Bundle 'tpope/vim-git'
Bundle 'tpope/vim-surround'
Bundle 'chikamichi/mediawiki.vim'
Bundle 'vim-pandoc/vim-pandoc'
Bundle 'Rip-Rip/clang_complete'
Bundle 'Shougo/neocomplcache'
Bundle 'osyo-manga/neocomplcache-clang_complete'
Bundle 'Shougo/vimshell'
" Syntax highlighting on
if has('syntax')
    syntax enable
    if exists(':highlight')
        highlight DiffAdd ctermfg=0 ctermbg=2 guibg='green'
        highlight DiffDelete ctermfg=0 ctermbg=1 guibg='red'
        highlight DiffChange ctermfg=0 ctermbg=3 guibg='yellow'
    endif
endif
set t_Co=256
set background=dark
" see :h filetype-overview
filetype plugin indent on
colorscheme solarized
if g:colors_name != 'solarized'
    colorscheme blackboard
endif
let mapleader = '\'
set nonumber
set textwidth=79
set tabstop=4
set shiftwidth=4
set expandtab
set matchpairs+=<:>
" don't automatically format text as it's typed
set formatoptions-=t
" when 'wrap' is enabled, use 'soft wrap', i.e., don't insert an eol into the buffer
set linebreak
set nowrap
" the movements can travel across line breaks
set whichwrap=h,l,~,[,]
" allow <BkSpc> to delete beyond the start of the current insertion, and over
" indentations:
set backspace=start,indent
" Show matching brackets
set showmatch
" Swap files all go into ~/.vim/swap if it exists
set directory=~/.vim/swap,.
" Keep 1000 file marks, 500 lines of registers max
if version >= 700
    set viminfo='1000,f1,<500
endif
" Save folds on exit and reload on load (only on non-readonly files)
"if !exists('saveview_loaded')
"    let saveview_loaded = 1
"    augroup saveview
"        autocmd BufWritePost * if !&readonly | mkview | endif
"        autocmd BufReadPost  * if !&readonly | silent loadview | endif
"    augroup end
"endif
set autoindent
set nohlsearch
set incsearch
set smartcase
set undolevels=200
set history=100
" Show what mode we're in at all times
set showmode
" Path/file matching in command mode like bash's
set wildmode=longest,list
" TAB is the next match key
set wildchar=<TAB>
" show a tab through menu
set wildmenu
set printoptions=paper:a4
if exists('+autochdir')
    set autochdir
elseif has("autocmd")
    autocmd BufEnter * silent! lcd Gav_fnameescape(expand('%:p:h'))
endif
set novisualbell
set noerrorbells
if has("gui_macvim")
    set vb " workaround to get rid of audible bell. still no visualbell :D
endif
" make c-u and c-w start a new change before running
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
inoremap <silent> <home> <C-O>:call Home()<CR>
nnoremap <silent> <home> :call Home()<CR>
" scroll left-right
nnoremap <C-l> zl
nnoremap <C-h> zh
" make
nnoremap <Leader>cc :make!<CR> <Bar> :copen<CR>
" next/previous error in quickfix
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
    " show number of chars/lines in visual selection
    set showcmd
endif
if has('statusline')
    " show statusline only if there are > 1 windows
    set laststatus=1
    " From spf13-vim
    " Broken down into easily includeable segments
    set statusline=%<%f\    " Filename
    set statusline+=%w%h%m%r " Options
    "set statusline+=%{fugitive#statusline()} "  Git Hotness
    set statusline+=\ [%{&ff}/%Y]            " filetype
    set statusline+=\ [%{getcwd()}]          " current dir
    set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    "my original set statusline=%<%f\ %=\:\b%n%y%m%r%w\ %l,%c%V\ %P
    set shortmess+=r
endif
if has('unix')
    nnoremap <silent> <Leader>p :call setreg("\"",system("xclip -o -selection clipboard"))<CR>p
    if !exists('g:x_clipboard_bug') || g:x_clipboard_bug == 0
        vnoremap <silent> <Leader>y y:call system("xclip -i -selection clipboard", getreg("\""))<CR>
    else
        " The reason for the double-command on <C-c> is due to some weirdness with the X clipboard system.
        vnoremap <silent> <Leader>y y:call system("xclip -i -selection clipboard", getreg("\""))<CR>:call system("xclip -i", getreg("\""))<CR>
    endif
"elseif has('win16') || has('win32') || has('win64') || has('win95') XXX no impl yet
else
    vnoremap <silent> <Leader>y "+y
    nnoremap <silent> <Leader>p "+p
endif
if exists('g:clipboard') && g:clipboard == 'macosx'
    vnoremap <silent> <Leader>y y:call system("pbcopy", getreg("\""))<CR>
    nnoremap <silent> <Leader>p :call setreg("\"",system("pbpaste"))<CR>p
endif

if has("autocmd")
    if exists("+omnifunc")
        autocmd Filetype *
            \   if &omnifunc == "" |
            \       setlocal omnifunc=syntaxcomplete#Complete |
            \   endif
    endif
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
            autocmd FileType make       setlocal noexpandtab shiftwidth=8
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

nnoremap <Leader>rr :redraw!<CR>
nnoremap <Leader>tn :set invnumber number?<CR>
nnoremap <Leader>tp :set invpaste paste?<CR>
nmap <F12> <Leader>tp
imap <F12> <C-O><Leader>tp
set pastetoggle=<F12>
nnoremap <Leader>tw :set invwrap wrap?<CR>
nnoremap <Leader>th :set invhls hls?<CR>
" toggle hard line wrapping at textwidth on and off
nnoremap <Leader>tf :if &fo =~ 't' <Bar> set fo-=t <Bar> else <Bar> set fo+=t <Bar>
  \ endif <Bar> set fo?<CR>
nnoremap <Leader>tl :set invlist list?<CR>
nnoremap <Leader>ts :set invspell spell?<CR>
nnoremap <Leader>tw :set invwrap wrap?<CR>
" ("diff no") turn off diff mode and report the change
nnoremap <Leader>dn :if &diff <Bar> diffoff <Bar> echo 'diffoff' <Bar> else <Bar> echo 'not in diff mode' <Bar> endif<CR>
" ("diff obtain") do :diffget on range and report the change:
" use "diff obtain" as that's what Vim itself uses for the non-range command: do
vnoremap <Leader>do :diffget <Bar> echo 'Left >>> Right'<CR>
" ("diff put") do :diffput on range and report the change:
vnoremap <Leader>dp :diffput <Bar> echo 'Left <<< Right'<CR>
" ("toggle bufmove") toggle m, and ,m moving from tab to buf and vice-versa
fun! Gav_SwitchBufMove()
    if !exists('g:buf_move') || g:buf_move == 'tab'
        let g:buf_move = 'buf'
        nnoremap m, :next<CR>
        nnoremap ,m :prev<CR>
    elseif g:buf_move == 'buf'
        if exists(':tabnext')
            let g:buf_move = 'tab'
            nnoremap m, :tabnext<CR>
            nnoremap ,m :tabprev<CR>
        endif
    endif
endfun
nnoremap <Leader>tb :call Gav_SwitchBufMove()<CR>
call Gav_SwitchBufMove()

function! AutoGitCommit(filename)
	execute 'silent! !git commit -m autocommit\ '.Gav_fnameescape(Gav_leaf(a:filename)).' '.Gav_fnameescape(a:filename)
endfunction
" 'AutoGitCommitWrites %:t' will run AutoGitCommit on each write
" Could be used in conjunction with set autowriteall
command! -nargs=1 -complete=file AutoGitCommitWrites autocmd BufWritePost <args> call AutoGitCommit(expand('<afile>:p'))

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
" NERD tree explorer plugin macro
nnoremap <Leader>nt :call GavFound(":NERDTreeToggle", "NERDTree")<CR>
nnoremap <Leader>nn :call GavFound(":NERDTree", "NERDTree")<CR>
" taglist plugin macro
nnoremap <Leader>tt :call GavFound(":TlistToggle", "Tlist")<CR>
" MultipleSearch plugin macros
nnoremap <Leader>ss :if exists(":Search") <Bar> :Search <Bar> else <Bar> :call GavMultipleSearchNotFound()<CR> <Bar> endif<CR>
nnoremap <Leader>sr :call GavFound(":Search", "MultipleSearch", ":SearchReset")<CR>
nnoremap <Leader>sb :if exists(":Search") <Bar> :SearchBuffers <Bar> else <Bar> :call GavMultipleSearchNotFound()<CR> <Bar> endif<CR>
nnoremap <Leader>sbr :call GavFound(":Search", "MultipleSearch", ":SearchBuffersReset")<CR>
nnoremap <Leader>si :call GavFound(":Search", "MultipleSearch", ":SearchReinit")<CR>
" fswitch plugin macro
nnoremap <Leader>fs :call GavFound(":FSHere", "fswitch")<CR>
nnoremap <Leader>fv :call GavFound(":FSSplitRight", "fswitch")<CR>
nnoremap ,t :call GavFound(":CommandT", "CommandT")<cr>
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
" grep plugin options
if !exists('g:Grep_Skip_Dirs')
    let g:Grep_Skip_Dirs = ''
else
    let g:Grep_Skip_Dirs = g:Grep_Skip_Dirs . ' '
endif
let g:Grep_Skip_Dirs = g:Grep_Skip_Dirs . '.git .svn .hg _darcs'
" grep plugin macros
nnoremap <Leader>gg :Grep<CR>
nnoremap <Leader>gf :Fgrep<CR>
nnoremap <Leader>ge :Egrep<CR>
nnoremap <Leader>ga :Agrep<CR>
nnoremap <Leader>grg :Rgrep<CR>
nnoremap <Leader>grf :Rfgrep<CR>
nnoremap <Leader>gre :Regrep<CR>
nnoremap <Leader>gra :Ragrep<CR>

" neocomplcache
let g:acp_enableAtStartup = 0
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_camel_case_completion = 1
" Use underbar completion.
let g:neocomplcache_enable_underbar_completion = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '\*ku\*'
" Plugin key-mappings.
imap <C-k> <Plug>(neocomplcache_snippets_expand)
smap <C-k> <Plug>(neocomplcache_snippets_expand)
inoremap <expr><C-g> neocomplcache#undo_completion()
inoremap <expr><C-l> neocomplcache#complete_common_string()
" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <expr><CR>  neocomplcache#smart_close_popup() . "\<CR>"
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplcache#close_popup()
inoremap <expr><C-e>  neocomplcache#cancel_popup()

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
