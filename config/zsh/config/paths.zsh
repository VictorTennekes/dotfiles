[[ -n "$_PATHS_SOURCED" ]] && return
typeset -g _PATHS_SOURCED=1

typeset -gU path

[[ -d "$HOME/.local/bin" ]]              && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/.krew/bin" ]]               && export PATH="$HOME/.krew/bin:$PATH"
[[ -d "$HOME/go/bin" ]]                  && export PATH="$HOME/go/bin:$PATH"
