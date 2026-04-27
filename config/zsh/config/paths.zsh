# Deduplicate PATH entries (prevents bloat across subshells)
typeset -gU path

# --- ~/.local/bin (npm --prefix=~/.local installs, mise itself, claude, etc.) ---
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# --- mise ---
# Adds mise shims to PATH for tool version management.
if [[ -d "$HOME/.local/share/mise/shims" ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi
