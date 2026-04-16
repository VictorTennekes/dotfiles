# Deduplicate PATH entries (prevents bloat across subshells)
typeset -gU path

# --- mise ---
# Adds mise shims to PATH for tool version management.
if [[ -d "$HOME/.local/share/mise/shims" ]]; then
  export PATH="$HOME/.local/share/mise/shims:$PATH"
fi
