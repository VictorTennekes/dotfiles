# SSH logins (phone via Tailscale) go straight into the "agents" session.
# exec: no leftover parent shell. Guards: not already nested, has a tty.
if [[ -n "$SSH_CONNECTION" && -z "$HERDR_ENV" && -z "$TMUX" && -t 0 ]]; then
  (( $+commands[herdr] )) && exec herdr --session agents
  (( $+commands[tmux] ))  && exec tmux new -A -s agents
fi

# Inside the "agents" session (or any SSH shell) git must not need the laptop
# screen: Bitwarden's SSH agent pops a GUI approval per signature, which nobody
# can click from a phone. Use the local remote key for auth + commit signing.
if [[ "$HERDR_SESSION" == agents || -n "$SSH_CONNECTION" ]]; then
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/id_ed25519_remote -o IdentitiesOnly=yes -o IdentityAgent=none"
  export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=user.signingkey GIT_CONFIG_VALUE_0="$HOME/.ssh/id_ed25519_remote"
fi
