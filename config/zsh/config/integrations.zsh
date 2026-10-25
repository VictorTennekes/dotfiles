# Cache tool init scripts to avoid subprocess spawns on every shell.
# Caches regenerate when the binary or this file (the init commands) is newer
# than the cache file.
_cache_init() {
  local name="$1" cmd="$2" dep stale=0; shift 2
  local cache_file="${ZSH_CACHE_DIR}/${name}.zsh"
  for dep in "$@" "${ZDOTDIR}/config/integrations.zsh"; do
    [[ "$dep" -nt "$cache_file" ]] && stale=1
  done
  if [[ ! -s "$cache_file" ]] || (( stale )); then
    eval "$cmd" > "$cache_file"
    # fzf's --zsh integration snapshots every zsh option and restores them with
    # `eval "options=(...)"`. That set includes the read-only `zle`/`monitor`
    # options, so zsh 5.9 warns "can't change option: zle" on every startup.
    # Silence just those two best-effort restores (portable sed, no -i).
    if [[ "$name" == fzf ]]; then
      sed 's|^\(  eval \$__fzf_[a-z_]*_options\)$|\1 2>/dev/null|' "$cache_file" \
        > "${cache_file}.tmp" && mv "${cache_file}.tmp" "$cache_file"
    fi
    # mise's output starts with a PATH snapshot of whichever shell generated
    # it (an IDE, an agent, `env -i`), which would then replace PATH in every
    # later shell. Drop it: the script re-reads the live PATH, and its
    # `_mise_hook --force` still adds the tool dirs.
    if [[ "$name" == mise ]]; then
      sed "/^export __MISE_ORIG_PATH='/d; /^export PATH='/d" "$cache_file" \
        > "${cache_file}.tmp" && mv "${cache_file}.tmp" "$cache_file"
    fi
  fi
  source "$cache_file"
}

# Use ${commands[...]} (zsh hash lookup) instead of $(command -v ...) to avoid forks
(( $+commands[fzf] ))      && _cache_init fzf      "fzf --zsh"            "${commands[fzf]}"
(( $+commands[zoxide] ))   && _cache_init zoxide   "zoxide init zsh --cmd cd" "${commands[zoxide]}"
(( $+commands[starship] )) && _cache_init starship "starship init zsh"    "${commands[starship]}"
(( $+commands[mise] ))     && _cache_init mise     "mise activate zsh"    "${commands[mise]}"
# mise's precmd hook forks `mise hook-env` on every prompt (~12ms). Keep only
# the chpwd hook: env refreshes on cd, not per prompt.
(( $+functions[_mise_hook_precmd] )) && add-zsh-hook -d precmd _mise_hook_precmd
