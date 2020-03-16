
if test -d ~/.rvm/bin && ! printf %s\\n "${PATH:-}" | grep -Fq "$HOME/.rvm/bin" ; then
    PATH="${PATH+$PATH:}$HOME/.rvm/bin" # Add RVM to PATH for scripting
fi

. ~/.fzf.zsh 2>/dev/null || true

# scriptcs version manager
. ~/.svm_profile 2>/dev/null || true
