" vi: set fenc=utf-8 sw=2 ts=2:
set nocompatible
set encoding=utf-8
scriptencoding utf-8
let s:is_purewin = has('win32') || has('win64')
let s:is_fakewin = has('win32unix')
let s:is_windows = s:is_purewin || s:is_fakewin
if s:is_purewin
  let s:vimfiles = expand('~/vimfiles')
  let s:vimrc = expand('~/_vimrc')
else
  let s:vimfiles = expand('~/.vim')
  let s:vimrc = expand('~/.vimrc')
endif
if has('nvim')
  let s:nativefiles = stdpath('config')
else
  let s:nativefiles = s:vimfiles
endif
call execute('source '.fnameescape(s:vimfiles.'/pre.vim'),'silent!')
if !exists('g:machine') | let g:machine = 'unknown' | endif
if !exists('g:cpp_expandtab') | let g:cpp_expandtab = 1 | endif
if !exists('g:cpp_textwidth') | let g:cpp_textwidth = 100 | endif
if !exists('mapleader') | let mapleader = ',' | endif
if !exists('g:mapleader') | let g:mapleader = ',' | endif
" `vim --cmd 'let g:none=1' ...` to disable all plugins at startup, including the plugin manager.
if !exists('g:none') | let g:none = 0 | endif
" `vim --cmd 'let g:min=1' ...` to disable many plugins at startup.
if !exists('g:min') | let g:min = 0 | endif
" `vim --cmd 'let g:justpm=1' ...` to disable all plugins at startup, except the plugin manager.
if !exists('g:justpm') | let g:justpm = 0 | endif
" `vim --cmd 'let g:coc=0' ...` to disable just coc.nvim -- also disabled by g:min, etc.
if !exists('g:coc') | let g:coc = 1 | endif
" When using ext:asvetliakov.vscode-neovim in Visual Studio Code.
if exists('g:vscode') | let g:none = 1 | endif

if g:none || g:justpm
  let s:plugins_min = 0
  let s:plugins_max = 0
elseif g:min
  let s:plugins_min = 1
  let s:plugins_max = 0
else
  let s:plugins_min = 1
  let s:plugins_max = 1
endif

" The below 2 filetype lines fix return code of vim on Mac OS X, when using pathogen.
" http://andrewho.co.uk/weblog/vim-pathogen-with-mutt-and-git
" I leave them here, even though I now use a different plugin manager.
filetype on
filetype off
let s:plugvim = s:nativefiles.'/autoload/plug.vim'
let s:plugged = s:vimfiles.'/plugged'
if !g:none
  if !filereadable(s:plugvim)
    if s:is_purewin
      if has('nvim')
        echomsg 'Auto-downloading junegunn/vim-plug to ~/AppData/Local/nvim/autoload/plug.vim'
        silent ! powershell -Command "
          \   New-Item -Path ~\AppData\Local\nvim -Name autoload -Type Directory -Force;
          \   Invoke-WebRequest
          \   -Uri 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
          \   -OutFile ~\AppData\Local\nvim\autoload\plug.vim
          \ "
      else
        echomsg 'Auto-downloading junegunn/vim-plug to ~/vimfiles/autoload/plug.vim'
        silent ! powershell -Command "
          \   New-Item -Path ~\vimfiles -Name autoload -Type Directory -Force;
          \   Invoke-WebRequest
          \   -Uri 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
          \   -OutFile ~\vimfiles\autoload\plug.vim
          \ "
      endif
    else
      if has('nvim')
        echomsg 'Auto-downloading junegunn/vim-plug to ~/.config/nvim/autoload/plug.vim'
        silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      else
        echomsg 'Auto-downloading junegunn/vim-plug to ~/.vim/autoload/plug.vim'
        silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
            \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      endif
    endif
    if filereadable(s:plugvim)
      autocmd VimEnter * PlugInstall --sync | execute 'source' fnameescape(s:vimrc)
    else
      echoerr 'Failed to auto-download junegunn/vim-plug'
    endif
  endif
  " let g:plug_shallow = 0
  call plug#begin(s:plugged)
  if s:plugins_max
    " Collection of heuristics to help quickly detect modifications in vim buffers.
    Plug 'def-lkb/vimbufsync'
    " Enable repeating supported plugin maps with '.'.
    Plug 'tpope/vim-repeat'
  " Syntax
    Plug 'jstrater/mpvim', {'for': ['portfile']}  " MacPorts
    Plug 'grisumbras/vim-b2', {'for': ['bbv2']}   " Boost.Build
    Plug 'chikamichi/mediawiki.vim', {'for': ['mediawiki']}
    Plug 'tpope/vim-markdown', {'for': ['markdown']}
    Plug 'vim-jp/cpp-vim', {'for': ['cpp']}
  endif
  if s:plugins_min
    Plug 'tpope/vim-git'  " Just syntax, format options, etc.
  " Pretty
    " Lean & mean status/tabline for vim that's light as air.
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
  endif
  if s:plugins_max
    " Optimized Solarized colorschemes. Best served with true-color terminals!
    Plug 'lifepillar/vim-solarized8'
  " Math
    " Mathematic symbols, e.g., \neq => ≠.
    Plug 'gu-fan/mathematic.vim'
    " Math on visual regions (sum, median, etc.).
    Plug 'EvanQuan/vmath-plus'
  " Programming

    if g:coc && v:version >= 800
      " Intellisense engine for Vim8 & Neovim, full language server protocol support as VSCode.
      "Plug 'neoclide/coc.nvim', {'branch': 'release'}
    endif
    " Show git status and diff when editing commit msg
    Plug 'rhysd/committia.vim'
    let g:indentLine_setColors = 0
    let g:indentLine_char_list = ['|', '¦', '┆', '┊']
    " Display the indention levels with thin vertical lines.
    Plug 'Yggdroot/indentLine'
    " Open a file on a given line, e.g., file.txt:20
    Plug 'bogado/file-line'
    " Switch between companion source files, e.g., h and cpp.
    Plug 'derekwyatt/vim-fswitch'
    " KISS local vimrc with hash protection.
    Plug 'MarcWeber/vim-addon-local-vimrc'
    " cscope keyboard mappings.
    Plug 'chazy/cscope_maps'
    "Plug 'tpope/vim-dispatch'
    " Syntax checking hacks for vim.
    Plug 'vim-syntastic/syntastic'
  endif
  if s:plugins_min
    " Define your own operator easily.
    Plug 'kana/vim-operator-user'
    " wisely add 'end' in ruby, endfunction/endif/more in vim script, etc.
    Plug 'tpope/vim-endwise'
    " Intensely nerdy commenting powers.
    Plug 'preservim/nerdcommenter'
    " Heuristically set buffer options.
    Plug 'tpope/vim-sleuth'
    " Better Rainbow Parentheses.
    Plug 'gavinbeatty/rainbow_parentheses.vim', {'branch': 'bugfix/toggle-all-chevrons'}
  endif
  if s:plugins_max
  " OCaml
    "if executable('opam')
    "  let g:opamshare = substitute(system('opam config var share'),'\n$','','''')
    "  execute 'set rtp+='.g:opamshare.'/merlin/vim'
    "  execute 'helptags '.g:opamshare.'/merlin/vim/doc'
    "endif
  " C++
    "if has('python3') && execute(':python3 import vim', 'silent!')
    "  set pyx=3
    "elseif has('python') && execute(':python import vim', 'silent!')
    "  set pyx=2
    "endif
    "if !s:is_windows && (has('python') || has('python3'))
    "  Plug 'lyuts/vim-rtags', {'for': ['c', 'cpp']}
    "endif
    "if has('python') || has('python3')
    "  Plug 'bbchung/clighter8', {'for': ['c', 'cpp']}
    "endif
  endif
  if s:plugins_min
    let g:clang_format#detect_style_file = 1
    Plug 'rhysd/vim-clang-format', {'for': ['c', 'cpp'], 'on': ['<Plug>(operator-clang-format)']}
  " Python
    "Plug 'ehamberg/vim-cute-python', {'for': ['python']}  " A bit too cute
  " Text
    Plug 'elzr/vim-json', {'for': ['json']}
    "Plug 'kana/vim-fakeclip'  " Don't see the point
    Plug 'godlygeek/tabular'
    " quoting/parenthesizing made simple.
    Plug 'tpope/vim-surround'
    Plug 'Lokaltog/vim-easymotion'
    Plug 'zirrostig/vim-schlepp'
    Plug 'gavinbeatty/hudigraphs_utf8.vim'
    Plug 'gavinbeatty/hlnext.vim'
    let s:wiki = {}
    if s:is_fakewin
      let s:homedir = system('cygpath -u "$USERPROFILE" | tr -d \\n')
      let s:wiki.path = s:homedir.'/work/gavinbeatty/wiki/'
    else
      let s:wiki.path = expand('~/work/gavinbeatty/wiki/')
    endif
    let s:wiki.syntax = 'markdown'
    let s:wiki.ext = '.mkd'
    let s:wiki.nested_syntaxes = {'python': 'python', 'cpp': 'cpp', 'csharp': 'cs'}
    let g:vimwiki_list = [s:wiki]
    let g:vimwiki_hl_headers = 1
    let g:vimwiki_hl_cb_checked = 1
    Plug 'vimwiki/vimwiki'
  " Files
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
  endif
  if s:plugins_max
    Plug 'mhinz/vim-startify'
  endif
  if s:plugins_min
    "let g:GPGPreferArmor = 1
    "Plug 'jamessan/vim-gnupg'  " Useful?
    " Quickly and easily switch between buffers (\be, etc.).
    Plug 'jlanzarotta/bufexplorer'
    if has('gui_running')
      " The fontsize controller in gVim (+, <C-ScrollWheelUp>, etc.).
      Plug 'thinca/vim-fontzoom', {'on': ['<Plug>(fontzoom-larger)', '<Plug>(fontzoom-smaller)']}
    endif
  endif
  call plug#end()
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
if v:version > 703 || (v:version == 703 && has('patch541'))
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
  if exists('+undofile') | set undofile | let &undodir=s:vimfiles.'/undo' | endif
  let &backupdir=s:vimfiles.'/backup'
  let &directory=s:vimfiles.'/swap'
  call s:EnsureDirExists(&undodir)
  call s:EnsureDirExists(&backupdir)
  call s:EnsureDirExists(&directory)
endif

"if s:is_purewin
"  let s:pwshexe = ''
"  if executable('pwsh.exe')
"    let s:pwshexe = 'pwsh.exe'
"  elseif executable('powershell.exe')
"    let s:pwshexe = 'powershell.exe'
"  endif
"  if !empty(s:pwshexe)
"    let &shell=s:pwshexe
"    set shellquote=( shellpipe=\| shellxquote=
"    set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
"    set shellredir=\|\ Out-File\ -Encoding\ UTF8
"  endif
"endif

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

if exists('*coc#refresh')
  set hidden
  set nobackup
  set nowritebackup
  set cmdheight=2
  set updatetime=300
  set shortmess+=c
  set signcolumn=yes

  " Use tab for trigger completion with characters ahead and navigate.
  " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
  " other plugin before putting this into your config.
  inoremap <silent><expr> <TAB>
        \ pumvisible() ? '\<C-n>' :
        \ <SID>check_back_space() ? '\<TAB>' :
        \ coc#refresh()
  inoremap <expr><S-TAB> pumvisible() ? '\<C-p>' : '\<C-h>'

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  " Use <c-space> to trigger completion.
  inoremap <silent><expr> <c-space> coc#refresh()

  " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
  " position. Coc only does snippet and additional edit on confirm.
  if has('patch8.1.1068')
    " Use `complete_info` if your (Neo)Vim version supports it.
    inoremap <expr> <cr> complete_info()['selected'] != '-1' ? '\<C-y>' : '\<C-g>u\<CR>'
  else
    imap <expr> <cr> pumvisible() ? '\<C-y>' : '\<C-g>u\<CR>'
  endif

  " Use `[g` and `]g` to navigate diagnostics
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    else
      call CocAction('doHover')
    endif
  endfunction

  " Highlight the symbol and its references when holding the cursor.
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Symbol renaming.
  nmap <leader>rn <Plug>(coc-rename)

  " Formatting selected code.
  xmap <leader>f  <Plug>(coc-format-selected)
  nmap <leader>f  <Plug>(coc-format-selected)

  augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end

  " Applying codeAction to the selected region.
  " Example: `<leader>aap` for current paragraph
  xmap <leader>a  <Plug>(coc-codeaction-selected)
  nmap <leader>a  <Plug>(coc-codeaction-selected)

  " Remap keys for applying codeAction to the current line.
  nmap <leader>ac  <Plug>(coc-codeaction)
  " Apply AutoFix to problem on the current line.
  nmap <leader>qf  <Plug>(coc-fix-current)

  " Introduce function text object
  " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
  xmap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap if <Plug>(coc-funcobj-i)
  omap af <Plug>(coc-funcobj-a)

  " Use <TAB> for selections ranges.
  " NOTE: Requires 'textDocument/selectionRange' support from the language server.
  " coc-tsserver, coc-python are the examples of servers that support it.
  nmap <silent> <TAB> <Plug>(coc-range-select)
  xmap <silent> <TAB> <Plug>(coc-range-select)

  " Add `:Format` command to format current buffer.
  command! -nargs=0 Format :call CocAction('format')

  " Add `:Fold` command to fold current buffer.
  command! -nargs=? Fold :call     CocAction('fold', <f-args>)

  " Add `:OR` command for organize imports of the current buffer.
  command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

  " Add (Neo)Vim's native statusline support.
  " NOTE: Please see `:h coc-status` for integrations with external plugins that
  " provide custom statusline: lightline.vim, vim-airline.
  set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  " Mappings using CoCList:
  " Show all diagnostics.
  nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
  " Manage extensions.
  nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
  " Show commands.
  nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
  " Find symbol of current document.
  nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
  " Search workspace symbols.
  nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
  " Do default action for next item.
  nnoremap <silent> <space>j  :<C-u>CocNext<CR>
  " Do default action for previous item.
  nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
  " Resume latest coc list.
  nnoremap <silent> <space>p  :<C-u>CocListResume<CR>
endif

if exists('*vmath_plus#report')
  " Analyze
  nmap <leader>ma <Plug>(vmath_plus#normal_analyze)
  nmap <leader>mba <Plug>(vmath_plus#normal_analyze_buffer)
  xmap <leader>ma <Plug>(vmath_plus#visual_analyze)
  xmap <leader>mba <Plug>(vmath_plus#visual_analyze_buffer)
  " Report
  nmap <leader>mr <Plug>(vmath_plus#report)
  nmap <leader>mbr <Plug>(vmath_plus#report_buffer)
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
if !exists(':DiffOrig')
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
if !has('nvim')
  " At least in nvim on windows this breaks backspace in insert mode.
  " The functionality already works without it, so ignore on nvim.
  " Change cursor position in insert mode.
  inoremap <C-h> <left>
  inoremap <C-l> <right>
endif
" Remap arrow keys.
nnoremap <down> :bprev<CR>
nnoremap <up> :bnext<CR>
nnoremap <left> :tabnext<CR>
nnoremap <right> :tabprev<CR>

" godlygeek/tabular
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

" (diff no) turn off diff mode and report the change
nnoremap <leader>dn :if &diff <Bar> diffoff <Bar> echo 'diffoff' <Bar> else <Bar> echo 'not in diff mode' <Bar> endif<CR>
" (diff obtain) do :diffget on range and report the change:
" use diff obtain as that's what Vim itself uses for the non-range command: do
vnoremap <leader>do :diffget <Bar> echo 'Left >>> Right'<CR>
" (diff put) do :diffput on range and report the change:
vnoremap <leader>dp :diffput <Bar> echo 'Left <<< Right'<CR>

nnoremap <leader>fs :FSHere<CR>
nnoremap <leader>fv :FSSplitRight<CR>
nnoremap <leader>fh :FSSplitAbove<CR>
nnoremap <silent> <leader>vn :call Svndiff('next')<CR>
nnoremap <silent> <leader>vp :call Svndiff('prev')<CR>
nnoremap <silent> <leader>vc :call Svndiff('clear')<CR>
let g:delimitMate_matchpairs = '(:),[:],{:}'

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

let g:syntastic_enable_highlighting = 1
"let g:syntastic_ignore_files = ['^/usr/include/', '/x_boost.*/', '^/opt/rh/devtoolset[^/]*/']
let g:syntastic_cs_checkers = ['syntax', 'semantic', 'issues']

nnoremap <leader>km :set keymap=mathematic<CR>
nnoremap <leader>kn :set keymap=<CR>
let s:mathematic_vim_dir = fnameescape(s:plugged.'/mathematic.vim/keymap/mathematic.vim')
nnoremap <leader>ks :exec 'sp '.s:mathematic_vim_dir<CR>
nnoremap <leader>kv :exec 'vs '.s:mathematic_vim_dir<CR>

call execute('source '.fnameescape(s:vimfiles.'/post.vim'),'silent!')
