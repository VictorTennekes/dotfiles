# Cache tool init scripts to avoid subprocess spawns on every shell.
# Caches regenerate when the binary is newer than the cache file.
_cache_init() {
  local name="$1" cmd="$2" bin="$3"
  local cache_file="${ZSH_CACHE_DIR}/${name}.zsh"
  if [[ ! -f "$cache_file" || "$bin" -nt "$cache_file" ]]; then
    eval "$cmd" > "$cache_file"
  fi
  source "$cache_file"
}

_cache_init fzf      "fzf --zsh"          "$(command -v fzf)"
_cache_init zoxide   "zoxide init zsh"    "$(command -v zoxide)"
_cache_init starship "starship init zsh"  "$(command -v starship)"
