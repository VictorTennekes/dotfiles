source ${ZDOTDIR}/config/cache.zsh
source ${ZDOTDIR}/config/exports.zsh
source ${ZDOTDIR}/config/paths.zsh
source ${ZDOTDIR}/config/history.zsh
source ${ZDOTDIR}/config/aliases.zsh
source ${ZDOTDIR}/config/completions.zsh
source ${ZDOTDIR}/config/functions.zsh
source ${ZDOTDIR}/config/integrations.zsh

# antidote: regenerate the static bundle if zsh_plugins.txt is newer (or it
# was bundled on a different machine — paths in the output are absolute).
_antidote_bundle="${ZSH_CACHE_DIR}/zsh_plugins_${HOST}.zsh"
if [[ ! -s "$_antidote_bundle" || "${ZDOTDIR}/zsh_plugins.txt" -nt "$_antidote_bundle" ]]; then
  _antidote_zsh="${HOMEBREW_PREFIX:+${HOMEBREW_PREFIX}/opt/antidote/share/antidote/antidote.zsh}"
  [[ -r "$_antidote_zsh" ]] || _antidote_zsh="$HOME/.local/share/antidote/antidote.zsh"
  if [[ -r "$_antidote_zsh" ]]; then
    source "$_antidote_zsh"
    antidote bundle <"${ZDOTDIR}/zsh_plugins.txt" >|"$_antidote_bundle"
  fi
  unset _antidote_zsh
fi
[[ -s "$_antidote_bundle" ]] && source "$_antidote_bundle"
unset _antidote_bundle

# Keybindings — deferred so widgets exist when bindings register
zsh-defer bindkey '^[[A' history-substring-search-up
zsh-defer bindkey '^[[B' history-substring-search-down

[[ -d "$HOME/.opencode/bin" ]] && export PATH="$HOME/.opencode/bin:$PATH"

[[ -f "${ZDOTDIR}/local.zsh" ]] && source "${ZDOTDIR}/local.zsh"
