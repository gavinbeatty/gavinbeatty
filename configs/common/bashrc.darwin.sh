# vi: set ft=sh expandtab tabstop=4 shiftwidth=4:
if test -n "${bashrc_darwin_guard-}" ; then return 0 ; fi
bashrc_darwin_guard=1
iecho ".bashrc.darwin.sh"

# macports
if (test -d "/opt/local/bin") && (! echo "${PATH:-}" | grep -Fq "/opt/local/bin") ; then
    PATH="${PATH:-}${PATH:+:}/opt/local/bin}" ; export PATH
fi
if (test -d "/opt/local/sbin") && (! echo "${PATH:-}" | grep -Fq "/opt/local/sbin") ; then
    PATH="${PATH:-}${PATH:+:}/opt/local/sbin}" ; export PATH
fi
v_="${PATH:-}"
n_="/Applications/MacVim.app/Contents/MacOS"
if test -d "$n_" && ! echo "$v_" | grep -Fq "$n_" ; then
    PATH="$n_${v_:+:}$v_" ; export PATH
fi
if type Vim >/dev/null 2>&1 ; then alias vim=Vim ; fi
if type mvim >/dev/null 2>&1 ; then alias gvim=mvim ; fi

# don't set MANPATH as it needs to contain all default manpage paths
# as well as MacPort's
v_="${SGML_CATALOG_FILES:-}"
n_="/opt/local/share/xsl/docbook-xsl/catalog.xml"
if (test -r "$n_") && (! echo "${v_:-}" | grep -Fq "$n_") ; then
    SGML_CATALOG_FILES="${v_:-}${v_:+:}$n_"
    export SGML_CATALOG_FILES
fi

alias spotlight-on='sudo mdutil -a -i on'
alias spotlight-off='sudo mdutil -a -i off'
