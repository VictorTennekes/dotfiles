# SSH logins (phone via Tailscale) go straight into the "agents" session.
# Not exec: if herdr/tmux fails, fall through to a plain shell as a rescue
# path instead of killing the login. Guards: not already nested, has a tty.
if [[ -n "$SSH_CONNECTION" && -z "$HERDR_ENV" && -z "$TMUX" && -t 0 ]]; then
  if (( $+commands[herdr] )); then
    herdr --session agents && exit
  elif (( $+commands[tmux] )); then
    tmux new -A -s agents && exit
  fi
  print -u2 "ssh.zsh: agents session failed, rescue shell."
fi
