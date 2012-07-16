" vi: set ft=vim expandtab tabstop=4 shiftwidth=4:
if !exists('b:did_ftplugin_cpp_vim')
let b:did_ftplugin_cpp_vim = 1

setlocal formatoptions=croql
setlocal list
setlocal cindent
setlocal makeprg=TERM=dumb\ bjam\ -j6\ link=static
setlocal makeef=bjam-build-errors.log
if g:cpp_expandtab
    setlocal expandtab
else
    setlocal noexpandtab
endif

iab #d #define
iab #i #include
iab #w #warning
iab #e #error
execute 'iab #m main(int argc, char* argv[])\n{\n\n}\n\n\n'
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
