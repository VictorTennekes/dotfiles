source ${ZDOTDIR}/config/exports.zsh
source ${ZDOTDIR}/config/paths.zsh

# Check if we're on the work laptop by hostname or any specific indicator
if [[ $(hostname) == PC-* ]]; then
    source ${ZDOTDIR}/work/exports.zsh
fi
