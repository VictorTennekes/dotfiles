# --- ZSH COMPLETION SYSTEM ---

# Load completions, creating the dump file at the specified path if it doesn't exist.
# The `-C` flag tells compinit that it's OK if the file is ignored (no big warning).
local zcompdump_path="${ZSH_CACHE_DIR}/.zcompdump"
autoload -Uz compinit
compinit -C -d "$zcompdump_path"

# Now, check if the dump file at the new path is more than 1 day old.
# The `(N.mh+24)` is a Zsh glob qualifier that checks the modification time.
if [[ -n "${zcompdump_path}(N.mh+24)" ]]; then
  # If it's old, regenerate it in the background at the specified path.
  compinit -i -d "$zcompdump_path" &!
fi

# --- Your Existing Config (Unchanged) ---

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.config/zsh
zstyle ':completion:*' compress end
