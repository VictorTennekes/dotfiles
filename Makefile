# ==============================================================================
# VARIABLES
# ==============================================================================
INSTALL_SCRIPT       ?= scripts/install
CLEAN_SCRIPT         ?= scripts/clean

REPO   := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
OS     := $(shell uname -s)
# bash, not sh: the Fedora dump target uses process substitution
SHELL  := /bin/bash
# Recursive makes ($(MAKE) update-packages) would announce every directory
MAKEFLAGS += --no-print-directory

# packages/fedora.txt without comments, one name per line (a shell pipeline;
# scripts/setup's pkglist is the same)
FEDORA_PKGS = sed 's/\#.*//' packages/fedora.txt | awk 'NF { print $$1 }'
# Work tap (Brewfile, ~/.work-laptop): brew refuses untrusted taps' formulae
BREW_TRUST  = brew trust -q hashicorp/tap can1357/tap areofyl/fetch >/dev/null || true

# ==============================================================================
# MAIN TARGETS
# ==============================================================================
all: install

# Guided, re-runnable setup (packages, links, keys, remote access).
install:
	@bash scripts/setup

# Same checks as install, but report only.
doctor:
	@bash scripts/setup --check

clean:
	@bash $(CLEAN_SCRIPT)

# ==============================================================================
# PACKAGES — Homebrew (macOS, bootstrapped by setup); Fedora uses
# packages/fedora.txt (dnf + Terra) via setup
# ==============================================================================
brew: packages/Brewfile
	@$(BREW_TRUST)
	@NONINTERACTIVE=1 brew bundle install -q --no-upgrade --file ./packages/Brewfile

# Sync installed packages to exactly match Brewfile (installs + removes).
brew-sync: brew
	@echo "🧹 Pruning packages not in Brewfile..."
	@brew bundle cleanup --force --file ./packages/Brewfile

# ==============================================================================
# MAINTENANCE
# ==============================================================================
# Pull, upgrade every package manager and nvim's plugins and tools, re-link.
# `up` (zsh) runs this. Quiet by design: each step prints what changed, not
# what it checked.
update:
	@echo "⬇️  Pulling latest dotfiles and nvim config..."
	@# config/nvim is its own repo; nvim-update.lua expects its current layout.
	@for r in $(REPO) $(REPO)/config/nvim; do [ -e "$$r/.git" ] || continue; \
		old=$$(git -C "$$r" rev-parse HEAD) && git -C "$$r" pull -q --rebase --autostash && \
		git -C "$$r" log --oneline "$$old..HEAD" | sed 's/^/  /' || exit 1; done
	@$(MAKE) update-packages
	@echo "📦 Updating zsh plugins..."
	@for d in "$${XDG_DATA_HOME:-$$HOME/.local/share}"/zsh-plugins/*/; do \
		[ -d "$$d" ] && git -C "$$d" pull -q; done; true
	@echo "📦 Updating Neovim plugins and Mason tools..."
	@nvim --headless "+luafile $(REPO)/scripts/nvim-update.lua" +qa
	@bash $(INSTALL_SCRIPT)
	@echo "✅ Update complete!"

ifeq ($(OS),Darwin)
# --greedy: also casks that update themselves (Ghostty, gcloud-cli,
# claude-code@latest); plain upgrade skips them.
# `brew update -q` still announces itself on stderr; drop that one line.
update-packages:
	@echo "📦 Updating brew packages..."
	@set -o pipefail; NONINTERACTIVE=1 brew update -q 2>&1 | { grep -v '^==> Updating Homebrew' || true; } && \
		NONINTERACTIVE=1 brew upgrade -q --greedy -y
	@$(MAKE) brew
	@brew cleanup -q --prune=all >/dev/null
else
# Install what's missing from the list and mark user-installed what isn't (see
# scripts/setup). Firmware (BIOS, touchpad, ...) via LVFS: report, never flash.
# dnf -q still says "Nothing to do." when there's nothing to upgrade.
update-packages:
	@echo "📦 Updating packages (dnf + Terra)..."
	@set -o pipefail; sudo dnf upgrade -y -q --refresh | { grep -vx 'Nothing to do.' || true; }
	@rpm -q --whatprovides $$($(FEDORA_PKGS)) 2>&1 | sed -n 's/^no package provides //p' | \
		xargs -r sudo dnf install -y --setopt=install_weak_deps=False
	@$(FEDORA_PKGS) | xargs dnf repoquery --installed --qf '%{name} %{reason}\n' 2>/dev/null | \
		awk '$$2 != "User" { print $$1 }' | xargs -r sudo dnf mark user -y -q
	@fwupdmgr refresh >/dev/null 2>&1; fwupdmgr get-updates >/dev/null 2>&1 && \
		echo "⚠️  Firmware updates available: run 'fwupdmgr update'" || true
endif

# Both lists are curated (grouped, commented, Brewfile's work block), so dump
# never overwrites them: it lists what's installed by hand but not listed.
ifeq ($(OS),Darwin)
# `brew bundle cleanup` without --force only lists (brew-sync removes them).
dump:
	@$(BREW_TRUST)
	@echo "📋 Installed but not in packages/Brewfile:"
	@brew bundle cleanup --file ./packages/Brewfile || true
else
# "By hand": install reason "User", not a dependency or the installer's group.
dump:
	@echo "📋 Installed by hand but not in packages/fedora.txt:"
	@comm -23 <(dnf repoquery --installed --qf '%{name} %{reason}\n' 2>/dev/null | \
		awk '$$2 == "User" { print $$1 }' | sort -u) <($(FEDORA_PKGS) | sort)
endif

# ==============================================================================
# VALIDATION
# ==============================================================================
# JSON with comments and trailing commas (waybar, fastfetch): strip both,
# string-aware, then parse.
JSONC_CHECK = import json, re, sys; s = open(sys.argv[1]).read(); \
	s = re.sub(r'("(?:\\.|[^"\\])*")|//[^\n]*|/\*.*?\*/', lambda m: m.group(1) or '', s, flags=re.S); \
	json.loads(re.sub(r',(\s*[]}])', r'\1', s))
export JSONC_CHECK

lint:
	@echo "🔍 Validating configs..."
	@for f in $(wildcard config/zsh/.zshrc home/.zshenv config/zsh/config/*.zsh config/zsh/config/functions/*); do \
		zsh -n "$$f" || exit 1; done && echo "  ✓ Zsh configs OK"
	@for f in config/fastfetch/config.jsonc home/.claude/settings.json; do \
		python3 -c "$$JSONC_CHECK" "$$f" || { echo "  ✗ $$f"; exit 1; }; done && echo "  ✓ JSON/JSONC OK"
	@if command -v noctalia >/dev/null; then \
		noctalia config validate || exit 1; echo "  ✓ noctalia config OK"; fi
	@if command -v umbriel >/dev/null; then \
		umbriel config validate >/dev/null || exit 1; echo "  ✓ umbriel config OK (stowed)"; fi
	@g=$$(command -v ghostty || ls /Applications/Ghostty.app/Contents/MacOS/ghostty 2>/dev/null); \
	if [ -n "$$g" ]; then "$$g" +validate-config >/dev/null && echo "  ✓ Ghostty config OK (stowed)" || exit 1; fi
	@shellcheck -S warning $(INSTALL_SCRIPT) $(CLEAN_SCRIPT) scripts/setup scripts/tpm-enroll scripts/macos-defaults config-linux/foot/reload config-linux/noctalia/plugins/tailscale/toggle config-macos/swiftbar/*.sh && echo "  ✓ Scripts OK (shellcheck)" || exit 1
	@echo "✅ All configs valid."

# ==============================================================================
# PHONY TARGETS
# ==============================================================================
.PHONY: all install doctor clean brew brew-sync update update-packages dump lint
