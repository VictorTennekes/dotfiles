alias c='clear'
alias ta='herdr --session agents'
alias g='git'
alias gho='gh repo view -w'
alias kx='kubectx'
alias tf="terraform"
alias v='nvim'
alias ctx='clip -h'  # files with headers, for LLM context

# File explorer (fzf → open selection in nvim)
alias f="fzf --preview 'bat --color=always {}' --preview-window '~3' --multi --bind 'enter:become(nvim {+})'"

# System replacements — guarded so a fresh machine without these tools still works
(( $+commands[bat] )) && alias cat='bat'
(( $+commands[eza] )) && alias ls='eza --icons --group-directories-first' ll='ls -la' lt='ls --tree --level=2'
