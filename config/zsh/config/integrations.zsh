# Tool init scripts cached (no subprocess per shell); regenerated when the
# tool's binary or this file (the init commands) is newer than the cache.
_cache_init() {
  local f=$ZSH_CACHE_DIR/$1.zsh
  [[ -s $f && $f -nt $commands[$1] && $f -nt $ZDOTDIR/config/integrations.zsh ]] || eval "$2" >| $f
  source $f
}
# fzf restores every option it saved, including the read-only zle/monitor ones:
# silence zsh 5.9's "can't change option: zle" on each of those two restores.
(( $+commands[fzf] ))    && _cache_init fzf 'fzf --zsh | sed "s/^  eval \$__fzf_[a-z_]*_options\$/& 2>\/dev\/null/"'
(( $+commands[zoxide] )) && _cache_init zoxide 'zoxide init zsh --cmd cd'
