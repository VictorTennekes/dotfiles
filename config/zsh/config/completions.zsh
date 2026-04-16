# Skip compinit security checks (faster startup)
zstyle ':zephyr:plugin:completion' disable-compfix 'yes'

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
zstyle ':completion:*' cache-path "$ZSH_CACHE_DIR"
zstyle ':completion:*' compress end

zstyle ':completion:*' rehash true

# kubectx/kubens alias completions (deferred until compinit is available)
function _register_kube_completions() {
  if (( $+commands[kubectx] )); then
    compdef _kubectx kx 2>/dev/null
    compdef _kubens kn 2>/dev/null
  fi
  add-zsh-hook -d precmd _register_kube_completions
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _register_kube_completions
