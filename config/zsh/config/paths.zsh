[[ -n "$_PATHS_SOURCED" ]] && return
typeset -g _PATHS_SOURCED=1

# (N/): only directories that exist.
typeset -gU path
path=($HOME/go/bin(N/) $HOME/.krew/bin(N/) $HOME/bin(N/) $HOME/.local/bin(N/) $path)
