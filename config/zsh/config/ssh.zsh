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

# Inside the "agents" session (or any SSH shell) git must not need the laptop
# screen: Bitwarden's SSH agent pops a GUI approval per signature, which nobody
# can click from a phone. Use the local remote key for auth + commit signing.
if [[ "$HERDR_SESSION" == agents || -n "$SSH_CONNECTION" ]]; then
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519_remote -o IdentitiesOnly=yes -o IdentityAgent=none"
  export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=user.signingkey GIT_CONFIG_VALUE_0="$HOME/.ssh/id_ed25519_remote"
fi
