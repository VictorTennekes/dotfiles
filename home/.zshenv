export ZDOTDIR=~/.config/zsh
# Skip macOS /etc/zprofile and /etc/zshrc: two forks (path_helper, locale) and a
# terminfo loop, ~9ms per login shell; .zshrc keeps the few bindings they set.
# Not on Fedora, whose /etc/zshrc sources /etc/profile.d.
[[ $OSTYPE == darwin* ]] && setopt no_global_rcs
# SSH sessions often arrive without a locale (Termius doesn't send one), which
# breaks Unicode in herdr. Terminals that set LANG keep theirs.
export LANG="${LANG:-en_US.UTF-8}"
