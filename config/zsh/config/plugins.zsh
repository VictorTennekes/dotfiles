# Autosuggestions: sync (the history strategy is a cheap lookup; async forks a
# subshell per keystroke) and bind widgets once instead of on every precmd
# (~10ms per prompt otherwise).
export ZSH_AUTOSUGGEST_MANUAL_REBIND=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# antidote: regenerate the static bundle if zsh_plugins.txt is newer (or it
# was bundled on a different machine — paths in the output are absolute).
_antidote_bundle="${ZSH_CACHE_DIR}/zsh_plugins_${HOST}.zsh"
if [[ ! -s "$_antidote_bundle" || "${ZDOTDIR}/zsh_plugins.txt" -nt "$_antidote_bundle" ]]; then
  # Homebrew on macOS, a git clone in ~/.local/share elsewhere
  for _antidote_zsh in "$HOMEBREW_PREFIX/opt/antidote/share/antidote/antidote.zsh" \
                       "${XDG_DATA_HOME:-$HOME/.local/share}/antidote/antidote.zsh"; do
    [[ -r "$_antidote_zsh" ]] && break
  done
  if [[ -r "$_antidote_zsh" ]]; then
    source "$_antidote_zsh"
    antidote bundle <"${ZDOTDIR}/zsh_plugins.txt" >|"$_antidote_bundle"
  fi
  unset _antidote_zsh
fi
[[ -s "$_antidote_bundle" ]] && source "$_antidote_bundle"
unset _antidote_bundle

# zsh-autosuggestions enables async at load time; async delivery needs `zle -F`,
# which never fires on this zsh once fsh/zsh-defer are loaded (see prompt.zsh),
# so suggestions silently stop. Sync is a cheap in-process history lookup.
zsh-defer -c 'unset ZSH_AUTOSUGGEST_USE_ASYNC'

# Keybindings — deferred so widgets exist when bindings register
zsh-defer bindkey '^[[A' history-substring-search-up
zsh-defer bindkey '^[[B' history-substring-search-down
