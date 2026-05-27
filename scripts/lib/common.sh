#!/usr/bin/env bash
# Shared, distro-agnostic install helpers for the per-distro installers
# (install-arch, install-fedora, install-void, …).
#
# Contract: the calling script must, before sourcing this, set PROJECT_ROOT and
# source its Packages.<distro> manifest (which declares the arrays referenced
# below — even if empty — so `set -u` stays happy):
#   FLATPAK_PACKAGES FLATPAK_PACKAGES_WORK CARGO_PACKAGES NPM_PACKAGES
#   SHELL_INSTALLERS SHELL_INSTALLERS_WORK  and  IS_WORK
#
# Everything here is package-manager-independent. Native package installation,
# extra repos (AUR/COPR/multilib), and desktop tweaks live in the per-distro
# script. Service enablement is portable (systemd + runit) via enable_service.

# ── pretty output ────────────────────────────────────────────────────────────
step()  { printf '\n\033[1;34m==>\033[0m \033[1m%s\033[0m\n' "$*"; }
say()   { printf '    %s\n' "$*"; }
warn()  { printf '\033[1;33m    ! %s\033[0m\n' "$*"; }

# ── sudo: prime once, keep warm for the whole run ────────────────────────────
# Long AUR/source compiles can outlast the sudo timestamp; refresh it so later
# privileged steps don't time out waiting for a password.
prime_sudo() {
  step "Sudo (cached for the whole run)"
  sudo -v || { warn "sudo is required for package installation"; exit 1; }
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true 2>/dev/null; sleep 50; done ) &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null' EXIT
}

# ── manifest loader ──────────────────────────────────────────────────────────
load_manifest() {
  local manifest="$1"
  if [[ ! -f "$manifest" ]]; then
    echo "❌ manifest not found at $manifest" >&2
    exit 1
  fi
  # shellcheck disable=SC1090
  source "$manifest"
}

# ── "name|command" idempotent vendor installers ──────────────────────────────
run_installers() {
  local entry name cmd
  for entry in "$@"; do
    name="${entry%%|*}"
    cmd="${entry#*|}"
    say "→ $name"
    bash -c "$cmd" || warn "$name failed (continuing)"
  done
}

install_shell_installers() {
  if [[ ${#SHELL_INSTALLERS[@]} -gt 0 ]]; then
    step "Shell installers"
    run_installers "${SHELL_INSTALLERS[@]}"
  fi
  if [[ "$IS_WORK" == "true" && ${#SHELL_INSTALLERS_WORK[@]} -gt 0 ]]; then
    step "Shell installers (work)"
    run_installers "${SHELL_INSTALLERS_WORK[@]}"
  fi
}

# ── flatpak (caller ensures flatpak itself is installed) ─────────────────────
install_flatpaks() {
  { [[ ${#FLATPAK_PACKAGES[@]} -gt 0 ]] || { [[ "$IS_WORK" == "true" ]] && [[ ${#FLATPAK_PACKAGES_WORK[@]} -gt 0 ]]; }; } || return 0
  if ! command -v flatpak >/dev/null 2>&1; then
    warn "flatpak not installed (add it to the native package list); skipping flatpaks"
    return 0
  fi
  flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
  if [[ ${#FLATPAK_PACKAGES[@]} -gt 0 ]]; then
    step "Flatpak apps"
    flatpak install --user -y --noninteractive flathub "${FLATPAK_PACKAGES[@]}" \
      || warn "some flatpaks failed (may not be on flathub yet — review above)"
  fi
  if [[ "$IS_WORK" == "true" && ${#FLATPAK_PACKAGES_WORK[@]} -gt 0 ]]; then
    step "Flatpak (work)"
    flatpak install --user -y --noninteractive flathub "${FLATPAK_PACKAGES_WORK[@]}" || true
  fi
}

# ── cargo / npm (user-level) ─────────────────────────────────────────────────
install_cargo() {
  [[ ${#CARGO_PACKAGES[@]} -gt 0 ]] || return 0
  step "Cargo packages"
  local pkg
  for pkg in "${CARGO_PACKAGES[@]}"; do
    if cargo install --list 2>/dev/null | grep -q "^${pkg} "; then
      say "$pkg already installed; skipping"
    else
      cargo install --locked "$pkg" || warn "$pkg failed"
    fi
  done
}

install_npm() {
  [[ ${#NPM_PACKAGES[@]} -gt 0 ]] || return 0
  step "NPM packages (user-level prefix)"
  mkdir -p "$HOME/.local"
  npm config set prefix "$HOME/.local" >/dev/null
  local pkg
  for pkg in "${NPM_PACKAGES[@]}"; do
    say "→ $pkg"
    npm install -g "$pkg" || warn "$pkg failed"
  done
}

# ── system/ overrides → / (idempotent, only writes when content differs) ─────
sync_system_overrides() {
  local system_dir="$PROJECT_ROOT/system"
  [[ -d "$system_dir" ]] || return 0
  step "System overrides (sudo)"
  local src rel dst
  while IFS= read -r -d '' src; do
    rel="${src#"$system_dir"/}"
    dst="/$rel"
    if ! sudo cmp -s "$src" "$dst" 2>/dev/null; then
      say "→ $dst"
      sudo install -Dm644 "$src" "$dst"
    else
      say "= $dst (already current)"
    fi
  done < <(find "$system_dir" -type f -print0)
}

# ── portable service enable: systemd OR runit (Void) ─────────────────────────
# Usage: enable_service tlp           (".service" suffix optional)
enable_service() {
  local svc="${1%.service}"
  if command -v systemctl >/dev/null 2>&1; then
    sudo systemctl enable --now "${svc}.service" 2>/dev/null \
      || warn "could not enable ${svc}.service (systemd)"
  elif [[ -d /etc/sv ]]; then          # runit (Void)
    if [[ -d "/etc/sv/$svc" ]]; then
      [[ -e "/var/service/$svc" ]] || sudo ln -s "/etc/sv/$svc" /var/service/ \
        || warn "could not link runit service $svc"
    else
      warn "no runit service dir /etc/sv/$svc — enable manually"
    fi
  else
    warn "unknown init system; enable '$svc' manually"
  fi
}

# ── default login shell → zsh ────────────────────────────────────────────────
ensure_default_shell() {
  if [[ "$SHELL" != *zsh ]] && command -v zsh >/dev/null 2>&1; then
    step "Default shell"
    say "setting login shell to zsh (may prompt for password)"
    chsh -s "$(command -v zsh)" || warn "chsh failed — set zsh as login shell manually"
  fi
}
