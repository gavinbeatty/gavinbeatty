" vi: set fenc=utf-8 sw=2 ts=2:
if has('win32') || has('win64')
  let s:vimfiles = expand('~/vimfiles')
  let s:vimrc = expand('~/_vimrc')
else
  let s:vimfiles = expand('~/.vim')
  let s:vimrc = expand('~/.vimrc')
endif
let &rtp=fnameescape(s:vimfiles).','.&rtp.','.fnameescape(s:vimfiles.'/after')
let &packpath = &runtimepath
execute('source '.fnameescape(s:vimrc))
