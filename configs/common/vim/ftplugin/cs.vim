" vi: set ft=vim expandtab tabstop=4 shiftwidth=4:
if !exists('b:did_ftplugin_cs_vim')
let b:did_ftplugin_cs_vim = 1

setlocal fileformat=dos
setlocal list cindent expandtab textwidth=4 tabstop=4
setlocal omnifunc=OmniSharp#Complete
setlocal updatetime=500
setlocal cmdheight=2

if exists(':SyntasticCheck') && exists('*OmniSharp#TypeLookupWithoutDocumentation')
  augroup cs_fswitch
    au BufEnter,TextChanged,InsertLeave *.cs SyntasticCheck
    au CursorHold *.cs call OmniSharp#TypeLookupWithoutDocumentation()
  augroup end
endif

nnoremap md :OmniSharpGotoDefinition<CR>
nnoremap <leader>mi :OmniSharpFindImplementations<CR>
nnoremap <leader>mt :OmniSharpFindType<CR>
nnoremap <leader>ms :OmniSharpFindSymbol<CR>
nnoremap <leader>mu :OmniSharpFindUsages<CR>
nnoremap <leader>mS :OmniSharpStartServer<CR>
nnoremap <leader>mP :OmniSharpStopServer<CR>

endif
