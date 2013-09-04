" vi: set ft=vim expandtab tabstop=4 shiftwidth=4:
if !exists('b:did_ftplugin_cpp_vim')
let b:did_ftplugin_cpp_vim = 1

setlocal formatoptions=croql list cindent ts=4 sw=4
setlocal makeprg=TERM=dumb\ bjam\ -j8
setlocal makeef=bjam-build-errors.log
" to ignore boost (since it's so big)
"setlocal include=^\\s*#\\s*include\ \\(<boost/\\)\\@!
if exists('g:cpp_textwidth') | let &l:textwidth = g:cpp_textwidth | endif
if exists('g:cpp_expandtab') | let &l:expandtab = g:cpp_expandtab | endif
let g:clang_use_library = 1
let g:clang_complete_auto = 1

iab #d #define
iab #i #include
iab #w #warning
iab #e #error
execute 'iab #m main(int argc, char* argv[])\n{\n\n}\n\n'
if has("autocmd")
    if !exists('cpp_fswitch_augroup')
        let cpp_fswitch_augroup = 1
        augroup cpp_fswitch
            autocmd BufEnter *.cpp let b:fswitchdst = 'hpp,h,hh' | let b:fswitchlocs = '.'
            autocmd BufEnter *.cc let b:fswitchdst = 'h,hh,hpp' | let b:fswitchlocs = '.'
            autocmd BufEnter *.hpp let b:fswitchdst = 'cpp' | let b:fswitchlocs = '.'
            autocmd BufEnter *.h let b:fswitchdst = 'cc,cpp,c' | let b:fswitchlocs = '.'
        augroup end
    endif
endif

endif
