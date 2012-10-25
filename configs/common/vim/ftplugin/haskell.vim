setlocal textwidth=2 tabstop=2 expandtab
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
nnoremap <leader>hl :HLint<cr>
nnoremap <leader>hs :%!stylish-haskell<cr>
nnoremap <leader>hp :HPaste<cr>
