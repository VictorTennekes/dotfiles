# Autoload custom functions — only parsed when first called
fpath+=(${ZDOTDIR}/config/functions)
autoload -Uz ${ZDOTDIR}/config/functions/*(.:t)
