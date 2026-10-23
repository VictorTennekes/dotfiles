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

# Git keys default to the no-approval Secretive "remote" key (config/ssh/config,
# ~/.gitconfig.local), so apps, T3 Code, phone and herdr sessions never wait on
# Touch ID. Local interactive terminals opt into "daily" (Touch ID per use) for
# auth + signing; ssh tries it first since Secretive lists it first.
if [[ -z "$SSH_CONNECTION" && "$HERDR_SESSION" != agents && -z "$T3CODE_CLI_PATH" ]]; then
  export GIT_SSH_COMMAND="ssh -i $HOME/.ssh/secretive-daily.pub"
  export GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=user.signingkey GIT_CONFIG_VALUE_0="$HOME/.ssh/secretive-daily.pub"
fi
