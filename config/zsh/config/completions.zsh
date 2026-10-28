# Homebrew's completions: Apple's /bin/zsh doesn't look there (Fedora's zsh
# already has its site-functions on fpath).
fpath=(/opt/homebrew/share/zsh/site-functions(N/) $fpath)
setopt always_to_end complete_in_word no_flow_control

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
# fzf-tab: its own menu instead of zsh's, with group headers
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' group-name ''
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --icons --group-directories-first --color=always $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'eza --icons --group-directories-first --color=always $realpath'
zstyle ':fzf-tab:complete:(cat|bat|v|nvim|less|head|tail):*' fzf-preview 'bat --color=always --style=numbers --line-range=:200 $realpath 2>/dev/null || eza --icons --color=always $realpath'
zstyle ':fzf-tab:complete:kill:*' fzf-preview 'ps -p $word -o pid,user,%cpu,%mem,command'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
