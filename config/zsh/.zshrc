autoload -Uz add-zsh-hook

# Order matters: cache sets ZSH_CACHE_DIR, completion zstyles precede zephyr,
# prompt undoes starship's prompt_subst from integrations.
for _f in cache exports paths history aliases completions functions integrations prompt ssh plugins; do
  source "${ZDOTDIR}/config/${_f}.zsh"
done
unset _f

[[ -f "${ZDOTDIR}/local.zsh" ]] && source "${ZDOTDIR}/local.zsh"
