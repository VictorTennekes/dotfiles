export ZDOTDIR=~/.config/zsh
# Terminal.app's per-window history files (macOS /etc/zshrc_Apple_Terminal);
# history goes to the one $HISTFILE set in cache.zsh.
export SHELL_SESSIONS_DISABLE=1
# SSH sessions often arrive without a locale (Termius doesn't send one), which
# breaks Unicode in herdr. Terminals that set LANG keep theirs.
export LANG="${LANG:-en_US.UTF-8}"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
