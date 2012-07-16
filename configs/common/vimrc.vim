" DON'T keep compatibility with vi
set nocompatible
source ~/.vimrc.pre.vim
if !exists('g:machine')
    let g:machine = 'unknown'
endif
if !exists('g:cpp_expandtab')
    let g:cpp_expandtab = 1
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
call pathogen#infect()
call pathogen#helptags()
" Syntax highlighting on
if has('syntax')
    syntax enable
    if exists(':highlight')
        highlight DiffAdd ctermfg=0 ctermbg=2 guibg='green'
        highlight DiffDelete ctermfg=0 ctermbg=1 guibg='red'
        highlight DiffChange ctermfg=0 ctermbg=3 guibg='yellow'
    endif
endif
" assume 256 color terminal
set t_Co=256
set background=dark
" see :h filetype-overview
filetype plugin indent on
colorscheme solarized
if g:colors_name != 'solarized'
    " fallback
    colorscheme blackboard
endif
let mapleader = '\'
set nonumber
set textwidth=79
set tabstop=4
set shiftwidth=4
set expandtab
" Match with % on <> pairs as well
set matchpairs+=<:>
" don't automatically format text as it's typed
set formatoptions-=t
" when formatting, use 'soft wrap', i.e., don't insert an eol into the buffer:
set linebreak
" Don't wrap lines by default
set nowrap
" h,j,k,l and ~ will now walk across line breaks
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
" Allow indenting automatically
set autoindent
" Turn off search highlighting
" It can be toggled with <Leader>th
set nohlsearch
" Do incremental search
set incsearch
" Do smart case searching: case insensitive when all lowercase/uppercase,
" sensitive otherwise
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
" use A4 instead of the default: US Letter size
set printoptions=paper:a4
" cd to the file's directory
if exists('+autochdir')
    set autochdir
"elseif has("autocmd")
    "autocmd BufEnter * silent! lcd Gav_fnameescape(expand('%:p:h'))
endif
" Flag problematic whitespace (trailing and spaces before tabs).
" Note you get the same by doing let c_space_errors=1 but this rule applies to
" everything.
"" I use trail: in listchars instead
"if has('autocmd')
"    highlight RedundantSpaces ctermbg=red guibg=red
"    match RedundantSpaces /\s\+$/
"    autocmd BufWinEnter * match RedundantSpaces /\s\+$/
"    autocmd InsertEnter * set listchars-=trail:
"    autocmd InsertLeave * match RedundantSpaces /\s\+$/
"    autocmd BufWinLeave * call clearmatches()
"endif
" Use :set list! or \tl (below) to toggle visible whitespace on/off
"set list
" Get rid of annoying beep and flash
set novisualbell           " no visual bell
set noerrorbells           " no audio bell
" make c-u and c-w start a new change before running
" http://vim.wikia.com/wiki/Recover_from_accidental_Ctrl-U
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
" Have Y act analogously to D and C
noremap Y y$
" Format selection
vnoremap Q gq
" Format paragraph
nnoremap Q gqap
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
    " en dash (built-in)
    "digraphs -N 8211
    " em dash (built-in)
    "digraphs -M 8212
    " quotation dash
    digraphs -Q 8213
    " figure dash
    digraphs -F 8210
endif
if has('cmdline_info')
    set ruler                  " show the ruler
    " a ruler on steroids
    set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
    set showcmd                " show partial commands in status line and
                               "   selected characters/lines in visual mode
endif
if has('statusline')
    set laststatus=1           " show statusline only if there are > 1 windows
    " a statusline, also on steroids
    set statusline=%<%f\ %=\:\b%n%y%m%r%w\ %l,%c%V\ %P
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
elseif has('win16') || has('win32') || has('win64') || has('win95')
    " XXX No implementation yet
else
    " if no specific implementation, use + register
    vnoremap <silent> <Leader>y "+y
    nnoremap <silent> <Leader>p "+p
endif
if exists('g:clipboard')
    if g:clipboard == 'macosx'
        vnoremap <silent> <Leader>y y:call system("pbcopy", getreg("\""))<CR>
        nnoremap <silent> <Leader>p :call setreg("\"",system("pbpaste"))<CR>p
    endif
endif
let g:haddock_browser = 'x-www-browser'
let g:pandoc_no_folding = 1

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

" redraw the screen
nnoremap <Leader>rr :redraw!<CR>
" ("toggle paste") toggle paste on/off and report the change, and
" where possible also have <F12> do this both in normal and insert mode:
nnoremap <Leader>tp :set invpaste paste?<CR>
nmap <F12> <Leader>tp
imap <F12> <C-O><Leader>tp
set pastetoggle=<F12>
" ("toggle wrap") toggle wrap on/off and report the change
nnoremap <Leader>tw :set invwrap wrap?<CR>
" ("toggle highlight") toggle highlighting of search matches, and
" report the change:
nnoremap <Leader>th :set invhls hls?<CR>
" ("toggle format") toggle the automatic insertion of line breaks
" during typing and report the change:
nnoremap <Leader>tf :if &fo =~ 't' <Bar> set fo-=t <Bar> else <Bar> set fo+=t <Bar>
  \ endif <Bar> set fo?<CR>
" ("toggle list") toggle list on/off and report the change:
nnoremap <Leader>tl :set invlist list?<CR>
" ("toggle spell") toggle spellchecker on/off and report the change:
nnoremap <Leader>ts :set invspell spell?<CR>
" ("toggle wrap") toggle wrap on/off and report the change:
nnoremap <Leader>tw :set invwrap wrap?<CR>
" ("diff no") turn off diff mode and report the change:
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

" Just make a simple git commit of a given file (relative to cwd).
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
let sep = ''
if exists('g:Grep_Skip_Dirs')
    let g:Grep_Skip_Dirs = g:Grep_Skip_Dirs . ' '
else
    let g:Grep_Skip_Dirs = ''
endif
let g:Grep_Skip_Dirs = g:Grep_Skip_Dirs . sep . ' .git .svn .hg'
" grep plugin macros
nnoremap <Leader>gg :Grep<CR>
nnoremap <Leader>gf :Fgrep<CR>
nnoremap <Leader>ge :Egrep<CR>
nnoremap <Leader>ga :Agrep<CR>
nnoremap <Leader>grg :Rgrep<CR>
nnoremap <Leader>grf :Rfgrep<CR>
nnoremap <Leader>gre :Regrep<CR>
nnoremap <Leader>gra :Ragrep<CR>

" gvim specific options
if has('gui_running')
    set guioptions-=T          " remove: T, the toolbar
    set guioptions-=L          " remove: L, the left-hand toolbar in vsplit
                               "         this fixes a bug where caret
                               "         disappears in vsplit in 7.2
    set lines=30               " 30 lines of text instead of 24,
                               "   perfect for 1024x768
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
    set mousemodel=popup       " hold right click for the usual kind of menu
    nmap <F11> :call IncrFontPt()<CR>
    nmap <F10> :call DecrFontPt()<CR>
endif
source ~/.vimrc.unicode.vim
source ~/.vimrc.post.vim
