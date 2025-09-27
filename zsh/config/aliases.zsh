# Aliasses
alias c='clear'
alias cdf='cd $(fzf)'
alias dots="cd ~/.dotfiles"
alias g='git'
alias gho='gh repo view -w'
alias glo='glab repo view -w'
alias kn='kubens'
alias kx='kubectx'
alias tf="terraform"
alias vf='nvim $(prev)'
alias vscode="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"

# Neovim
alias v='nvim'

# File explorer
alias f="fzf --preview 'bat --color=always {}' --preview-window '~3' --multi --bind 'enter:become(nvim {+})'"

# System replacements
alias cat='bat'
alias cd='z'
alias ls='eza --icons --group-directories-first'
