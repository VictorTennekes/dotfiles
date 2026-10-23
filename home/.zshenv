export ZDOTDIR=~/.config/zsh
# SSH sessions often arrive without a locale (Termius doesn't send one), which
# breaks Unicode in herdr. Terminals that set LANG keep theirs.
export LANG="${LANG:-en_US.UTF-8}"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
