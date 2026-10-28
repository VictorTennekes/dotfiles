# Async starship (8-50ms per render): reuse the last prompt, re-render in the
# background and swap it in from a `zle -F -w` widget. Sync after cd (the old
# prompt has the wrong directory). No `starship init`: nothing to undo.
(( $+commands[starship] )) || return
export STARSHIP_SHELL=zsh
PROMPT2='%F{8}∙%f '
typeset -g _sp_fd _sp_pwd
_sp_done() {
  zle -F $_sp_fd
  IFS= read -r -u $_sp_fd -d '' PROMPT
  exec {_sp_fd}<&-
  _sp_fd=
  zle reset-prompt
}
zle -N _sp_done
_sp_precmd() {
  local -a a=(--status=$? --pipestatus="${pipestatus[*]}" --terminal-width=$COLUMNS)
  # zsh-defer calls precmd hooks after each deferred plugin load; nothing changed.
  [[ -n $zsh_defer_options ]] && return
  if [[ -n $_sp_fd ]]; then zle -F $_sp_fd; exec {_sp_fd}<&-; _sp_fd=; fi
  if [[ $PWD != $_sp_pwd ]]; then _sp_pwd=$PWD; PROMPT=$(starship prompt $a); return; fi
  exec {_sp_fd}< <(starship prompt $a)
  zle -F -w $_sp_fd _sp_done
}
precmd_functions+=(_sp_precmd)
