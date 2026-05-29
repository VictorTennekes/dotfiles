# Autoload custom functions — only parsed when first called
typeset -gU fpath
fpath+=(${ZDOTDIR}/config/functions)
autoload -Uz ${ZDOTDIR}/config/functions/*(.:t)
