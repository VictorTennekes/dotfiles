# The async prompt needs `zle -F` alive (see CLAUDE.md): compinit now, plugins
# deferred with -psz, sync autosuggestions, which bind their widgets once.
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1

# compinit from a cached dump; the full compinit (security audit skipped) only
# reruns when fpath or one of its dirs changed (a new completion file changes
# the dir's mtime; the dump only lists names, so edits in place don't matter).
_zcd=$ZSH_CACHE_DIR/zcompdump
autoload -Uz compinit
[[ -r $_zcd.fpath && "$(<$_zcd.fpath)" == "$fpath" ]] || rm -f $_zcd
for _d in $fpath; do [[ $_d -nt $_zcd ]] && rm -f $_zcd; done
if [[ -f $_zcd ]]; then compinit -C -d $_zcd
else compinit -u -d $_zcd; zcompile $_zcd; print -r -- "$fpath" >| $_zcd.fpath; fi
unset _zcd _d

# Git clones of zsh_plugins.txt (scripts/setup), zsh_unplugged-style; a missing
# clone is skipped. Everything after zsh-defer is deferred.
_zp_root="${XDG_DATA_HOME:-$HOME/.local/share}/zsh-plugins"
while read -r _zp_repo _zp_sub; do
  [[ -z $_zp_repo || $_zp_repo == \#* ]] && continue
  _zp_dir="$_zp_root/${_zp_repo:t}${_zp_sub:+/$_zp_sub}"
  _zp_file=("$_zp_dir"/*.plugin.zsh(N))
  (( $#_zp_file )) || continue
  fpath+=("$_zp_dir")
  if (( $+functions[zsh-defer] )); then zsh-defer -psz source "$_zp_file[1]"; else source "$_zp_file[1]"; fi
done <"${ZDOTDIR}/zsh_plugins.txt"
unset _zp_root _zp_repo _zp_sub _zp_dir _zp_file
# No zsh-defer clone: the deferred line below runs right away.
(( $+functions[zsh-defer] )) || zsh-defer() { shift; if [[ $1 == -c ]]; then eval "$2"; else "$@"; fi }

# After the plugins load: sync suggestions, and keys for their widgets.
zsh-defer -psz -c "unset ZSH_AUTOSUGGEST_USE_ASYNC
  bindkey '^[[A' history-substring-search-up '^[[B' history-substring-search-down"
