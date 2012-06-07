" vi: set ft=vim expandtab tabstop=4 shiftwidth=4:
set formatoptions=croql
iab #d #define
iab #i #include
iab #w #warning
iab #e #error
execute 'iab #m main(int argc, char* argv[])\n{\n\n}\n\n\n'
set cindent
