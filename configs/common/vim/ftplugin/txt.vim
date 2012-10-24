" vi: set ft=vim expandtab tabstop=4 shiftwidth=4:
if !exists('b:did_ftplugin_sh_vim')
let b:did_ftplugin_sh_vim = 1
setlocal formatoptions=tcqn2 textwidth=80 linebreak list smartindent spell spelllang=en_gb
map <buffer> j gj
map <buffer> k gk
endif
