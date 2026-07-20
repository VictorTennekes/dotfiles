# Cache tool init scripts to avoid subprocess spawns on every shell.
# Caches regenerate when the binary is newer than the cache file.
_cache_init() {
  local name="$1" cmd="$2" bin="$3"
  local cache_file="${ZSH_CACHE_DIR}/${name}.zsh"
  if [[ ! -s "$cache_file" || "$bin" -nt "$cache_file" ]]; then
    eval "$cmd" > "$cache_file"
    # fzf's --zsh integration snapshots every zsh option and restores them with
    # `eval "options=(...)"`. That set includes the read-only `zle`/`monitor`
    # options, so zsh 5.9 warns "can't change option: zle" on every startup.
    # Silence just those two best-effort restores (portable sed, no -i).
    if [[ "$name" == fzf ]]; then
      sed 's|^\(  eval \$__fzf_[a-z_]*_options\)$|\1 2>/dev/null|' "$cache_file" \
        > "${cache_file}.tmp" && mv "${cache_file}.tmp" "$cache_file"
    fi
  fi
  source "$cache_file"
}

# Use ${commands[...]} (zsh hash lookup) instead of $(command -v ...) to avoid forks
(( $+commands[fzf] ))      && _cache_init fzf      "fzf --zsh"            "${commands[fzf]}"
(( $+commands[zoxide] ))   && _cache_init zoxide   "zoxide init zsh"      "${commands[zoxide]}"
(( $+commands[starship] )) && _cache_init starship "starship init zsh"    "${commands[starship]}"
(( $+commands[mise] ))     && _cache_init mise     "mise activate zsh"    "${commands[mise]}"

# Async autosuggestions — generate suggestions in background to keep ZLE responsive
export ZSH_AUTOSUGGEST_USE_ASYNC=1
export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
