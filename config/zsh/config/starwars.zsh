# Star Wars flair
alias starwars='open https://www.asciimation.co.nz/'

# Random quote on new interactive shell
if [[ -o interactive ]]; then
  local _sw_db="${ZDOTDIR}/data/starwars"
  local _sw_quote=""

  if (( $+commands[fortune] )) && [[ -f $_sw_db ]]; then
    # Build the .dat index lazily on first use
    if [[ ! -f ${_sw_db}.dat ]] && (( $+commands[strfile] )); then
      strfile -s "$_sw_db" >/dev/null 2>&1
    fi
    [[ -f ${_sw_db}.dat ]] && _sw_quote=$(fortune "$_sw_db" 2>/dev/null)
  fi

  if [[ -z $_sw_quote ]]; then
    local -a _sw_fallback=(
      "Do. Or do not. There is no try.  — Yoda"
      "I find your lack of faith disturbing.  — Vader"
      "Hello there.  — General Kenobi"
      "Never tell me the odds!  — Han"
      "It's a trap!  — Ackbar"
    )
    _sw_quote=${_sw_fallback[RANDOM % ${#_sw_fallback[@]} + 1]}
    unset _sw_fallback
  fi

  print -P "%F{yellow}✦%f $_sw_quote"
  unset _sw_db _sw_quote
fi
