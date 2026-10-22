# Async starship. `starship prompt` forks twice per prompt (left + right) and
# runs git status: 8-50ms of synchronous lag. Instead reuse the previous prompt
# instantly, re-render in a background process and swap it in via zle -F once
# the result is readable. After cd the old prompt would show the wrong
# directory, so render in sync then.
(( $+commands[starship] )) || return
# starship's init turns prompt_subst on for its PROMPT='$(starship …)'. We put
# the rendered text in PROMPT directly, so it must not be expanded again
# (`[$!?]` would turn `$!` into a job PID).
unsetopt prompt_subst
typeset -g _sp_fd _sp_left _sp_right _sp_chpwd=1
_sp_chpwd() { _sp_chpwd=1 }
_sp_done() {
  local fd=$1
  zle -F $fd
  IFS= read -r -u $fd -d '' _sp_left
  IFS= read -r -u $fd -d '' _sp_right
  exec {fd}<&-
  _sp_fd=
  PROMPT=$_sp_left RPROMPT=$_sp_right
  zle && zle reset-prompt
}
_sp_precmd() {
  # zsh-defer calls precmd hooks after each deferred plugin load; nothing changed.
  [[ -n $zsh_defer_options ]] && return
  local -a a=(--terminal-width="$COLUMNS" --keymap="${KEYMAP:-}" --status="${STARSHIP_CMD_STATUS:-}" --pipestatus="${STARSHIP_PIPE_STATUS[*]:-}" --cmd-duration="${STARSHIP_DURATION:-}" --jobs="$STARSHIP_JOBS_COUNT")
  if [[ -n $_sp_fd ]]; then zle -F $_sp_fd; exec {_sp_fd}<&-; _sp_fd=; fi
  if (( _sp_chpwd )); then
    _sp_chpwd=0
    _sp_left=$(starship prompt $a) _sp_right=$(starship prompt --right $a)
    PROMPT=$_sp_left RPROMPT=$_sp_right
    return
  fi
  PROMPT=$_sp_left RPROMPT=$_sp_right
  exec {_sp_fd}< <(starship prompt $a; print -n $'\0'; starship prompt --right $a)
  zle -F $_sp_fd _sp_done
}
add-zsh-hook precmd _sp_precmd
add-zsh-hook chpwd _sp_chpwd
