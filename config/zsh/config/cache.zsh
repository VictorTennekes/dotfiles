[[ -n "$_CACHE_SOURCED" ]] && return
typeset -g _CACHE_SOURCED=1

# --- Zsh Cache & History Location ---
export ZSH_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
export HISTFILE="${ZSH_CACHE_DIR}/.zsh_history"

# --- Create Zsh Directories (if they don't exist) ---
[[ -d "$ZSH_CACHE_DIR" ]] || mkdir -p "$ZSH_CACHE_DIR"
[[ -d "${ZSH_CACHE_DIR}/zsh_sessions" ]] || mkdir -p "${ZSH_CACHE_DIR}/zsh_sessions"
