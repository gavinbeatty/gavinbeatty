setlocal et ts=2 sw=2
" For hothasktags
setlocal iskeyword=a-z,A-Z,_,.,39
"setlocal omnifunc=necoghc#omnifunc
nnoremap <buffer> <localleader>l :HLint<cr>
nnoremap <buffer> <localleader>s :%!stylish-haskell<cr>
nnoremap <buffer> <localleader>p :HPaste<cr>
nnoremap <buffer> <localleader>ho :call GavFound(":Unite", "Unite", ":Unite -start-insert hoogle")<CR>
