export ZDOTDIR=~/.config/zsh
# SSH sessions arrive with no locale (sshd drops the client's); mosh-server
# refuses to start without UTF-8. Terminals that set LANG keep theirs.
export LANG="${LANG:-en_US.UTF-8}"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
