[[ -n "$_PATHS_SOURCED" ]] && return
typeset -g _PATHS_SOURCED=1

# (N/): only directories that exist.
typeset -gU path
path=($HOME/go/bin(N/) $HOME/.krew/bin(N/) $HOME/bin(N/) $HOME/.local/bin(N/) $path)

# mise only installs the global node/python/go (~/.config/mise/config.toml);
# its lts/latest links follow `mise upgrade`. No shell hook: that cost ~19ms
# per new shell and per cd, for per-directory switching nothing here uses
# (uv reads .python-version itself). Run `mise x -- <cmd>` if a project
# pins versions in mise.toml.
_mise_installs=${XDG_DATA_HOME:-$HOME/.local/share}/mise/installs
path=($_mise_installs/{node/lts,python/latest,go/latest}/bin(N/) $path)
unset _mise_installs
