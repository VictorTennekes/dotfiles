autoload -Uz add-zsh-hook

# Order matters: cache sets ZSH_CACHE_DIR, ssh execs into herdr as soon as
# PATH is ready (skipping the rest), completion zstyles precede zephyr,
# prompt undoes starship's prompt_subst from integrations.
for _f in cache exports paths ssh history aliases completions functions integrations prompt plugins; do
  source "${ZDOTDIR}/config/${_f}.zsh"
done
unset _f

[[ -f "${ZDOTDIR}/local.zsh" ]] && source "${ZDOTDIR}/local.zsh"
