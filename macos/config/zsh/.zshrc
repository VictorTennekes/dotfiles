source /opt/homebrew/opt/antidote/share/antidote/antidote.zsh

source ${ZDOTDIR}/config/aliases.zsh
source ${ZDOTDIR}/config/cache.zsh
source ${ZDOTDIR}/config/completions.zsh
source ${ZDOTDIR}/config/functions.zsh
source ${ZDOTDIR}/config/history.zsh
source ${ZDOTDIR}/config/integrations.zsh

source ${ZDOTDIR}/work/init.zsh

. "$HOME/.local/bin/env"

antidote load ${ZDOTDIR}/zsh_plugins.txt
eval "$(starship init zsh)"
