# What macOS /etc/zshrc used to set (skipped: no_global_rcs in ~/.zshenv).
# Emacs keymap explicitly: zle picks vi when EDITOR contains "vi" (nvim).
setopt combining_chars
bindkey -e
bindkey '^[[3~' delete-char '^[[H' beginning-of-line '^[OH' beginning-of-line '^[[F' end-of-line '^[OF' end-of-line
disable log

# Custom functions, parsed on first call.
fpath+=($ZDOTDIR/config/functions)
autoload -Uz $ZDOTDIR/config/functions/*(.:t)

# Order matters: ssh execs into herdr as soon as PATH is ready (skipping the
# rest), history sets ZSH_CACHE_DIR, plugins runs compinit after the tool inits.
for _f in exports ssh history aliases completions integrations prompt plugins; do
  source "${ZDOTDIR}/config/${_f}.zsh"
done
unset _f

[[ -f "${ZDOTDIR}/local.zsh" ]] && source "${ZDOTDIR}/local.zsh"
