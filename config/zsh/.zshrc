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
_antidote_bundle="${ZSH_CACHE_DIR}/zsh_plugins.zsh"
if [[ ! -s "$_antidote_bundle" || "${ZDOTDIR}/zsh_plugins.txt" -nt "$_antidote_bundle" ]]; then
  if [[ -r "$HOME/.local/share/antidote/antidote.zsh" ]]; then
    source "$HOME/.local/share/antidote/antidote.zsh"
    antidote bundle <"${ZDOTDIR}/zsh_plugins.txt" >|"$_antidote_bundle"
  fi
fi
[[ -s "$_antidote_bundle" ]] && source "$_antidote_bundle"
unset _antidote_bundle
