# Completion styling (compinit is handled by zephyr's completion plugin)
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --group-directories-first --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --icons --group-directories-first --color=always $realpath'
zstyle ':fzf-tab:complete:(cat|bat|v|nvim|less|head|tail):*' fzf-preview 'bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null || eza --icons --color=always $realpath'
zstyle ':fzf-tab:complete:kill:*' fzf-preview 'ps -p $word -o pid,user,%cpu,%mem,command'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.config/zsh
zstyle ':completion:*' compress end

zstyle ':completion:*' rehash true
