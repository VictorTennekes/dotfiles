# Aliases
alias c='clear'
# attach to the 'agents' session (create if missing); SSH logins do this automatically
#   (see ssh.zsh). herdr = tmux-like, shows per-pane agent status.
alias ta='herdr --session agents'
alias dots="cd ~/.dotfiles"
alias g='git'
alias gho='gh repo view -w'
alias glo='glab repo view -w'
alias kn='kubens'
alias kx='kubectx'
alias tf="terraform"
# Neovim
alias v='nvim'

# File explorer (fzf → open selection in nvim)
alias f="fzf --preview 'bat --color=always {}' --preview-window '~3' --multi --bind 'enter:become(nvim {+})'"

# System info

# LLM helpers
alias tc='eza --tree --git-ignore -I .git | clip'

# System replacements — guarded so a fresh machine without these tools still works
(( $+commands[bat]    )) && alias cat='bat'
if (( $+commands[eza] )); then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --icons --group-directories-first -la'
  alias lt='eza --icons --group-directories-first --tree --level=2'
fi
