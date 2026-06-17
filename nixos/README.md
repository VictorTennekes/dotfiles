# NixOS on r2d2 (Framework 13 AMD, Ryzen AI 7 350)

Turnkey **all-in** install: wipes `/dev/nvme0n1` entirely (Arch + Void + Fedora
+ shared data) for a single GNOME NixOS install on btrfs, with hibernate.

> r2d2 is the *tinkering* laptop (primary machine is an M1 MacBook Pro), so
> there is **no on-disk fallback** — the recovery USB is the safety net.

## What this config does

- **Disk** (`disko.nix`): ESP 1G + 36G swap (hibernate) + btrfs root with
  `@ @home @nix @log @snapshots` (zstd, noatime).
- **Boot**: systemd-boot, latest kernel (Zen5), generations capped at 5.
- **Desktop**: GNOME on Wayland; PipeWire; power-profiles-daemon; fprintd; fwupd.
- **Hardware**: `nixos-hardware` `framework-amd-ai-300-series` module.
- **Packages** (`packages.nix`): the Linux package manifest (Brewfile is macOS).
- **Dotfiles**: NOT managed by Nix — stowed from `../config` exactly like
  macOS/Arch (keeps the repo portable). Nix only does packages + system.

---

## 0. Pre-flight backup (from the current Arch system)

Nothing here is large; the only irreplaceable bits:

```sh
# 1. Push the unpushed dotfiles WIP commit (b203ec9) — or it's gone forever.
git -C ~/.dotfiles push origin HEAD

# 2. Copy real data + secrets to a USB stick (or cloud).
#    SSH keys are in Bitwarden already — nothing to save there.
cp -a /data ~/.gnupg ~/odysseus  /run/media/$USER/BACKUP/   # adjust mount path
git -C ~/odysseus status   # commit/push the 1 dirty file if it matters
```

## 1. Build the installer USB

On any machine: download the **NixOS minimal/GNOME ISO** (unstable or latest
release), then:

```sh
sudo dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

## 2. Boot the USB → get online

```sh
# Wi-Fi (graphical ISO has NetworkManager):
nmcli device wifi connect "<SSID>" password "<pass>"
# Minimal ISO uses iwd:  iwctl station wlan0 connect <SSID>
ping -c1 nixos.org
```

## 3. Fetch this config

```sh
nix-shell -p git --run 'git clone https://github.com/VictorTennekes/dotfiles /tmp/dotfiles'
cd /tmp/dotfiles/nixos
```

## 4. Partition + format — ⚠️ DESTROYS THE DISK

```sh
sudo nix --experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount --yes-wipe-all-disks ./disko.nix
# everything ends up mounted under /mnt
```

## 5. Generate the exact hardware profile, then install

```sh
# disko owns filesystems → --no-filesystems. This refines kernel modules
# for this specific unit; copy it over the placeholder in the repo:
sudo nixos-generate-config --no-filesystems --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix ./hardware-configuration.nix

sudo nixos-install --flake .#r2d2
sudo nixos-enter --root /mnt -c 'passwd victortennekes'
reboot   # remove the USB
```

## 6. First boot — restore the rest

```sh
# Re-clone dotfiles to the canonical location and stow configs (same as Arch):
git clone git@github.com:VictorTennekes/dotfiles ~/.dotfiles   # or https first
cd ~/.dotfiles && make install        # stows config/ via GNU Stow

# Restore data + secrets from the USB:
cp -a /run/media/$USER/BACKUP/data/*   ~/    # Downloads, Pictures, Projects...
cp -a /run/media/$USER/BACKUP/.gnupg   ~/
cp -a /run/media/$USER/BACKUP/odysseus ~/

# Bitwarden unlocks the SSH agent (signing + auth) and secrets:
bw login
# CLIs (bw, gemini, opencode, claude-code) are declarative in packages.nix —
# nothing to npm/curl-install here anymore.
```

### Machine-local git identity (not in the repo)

`config/git/config` keeps identity + signature trust out of the tracked tree
via two host-local files. The Bitwarden SSH agent serves the signing key, but
git still needs to know who you are and which key to trust — create both:

```sh
cat > ~/.gitconfig.local <<'EOF'
[user]
	name = Your Name
	email = you@example.com
EOF

# allowed_signers lets `git log --show-signature` verify locally (else it
# reports the signature as untrusted). Read both values back from the config
# you just set so nothing is hardcoded here:
mkdir -p ~/.ssh
printf '%s %s\n' "$(git config user.email)" "$(git config user.signingkey)" \
  > ~/.ssh/allowed_signers
```

> If the BW agent socket isn't picked up (native, non-Flatpak install), it
> lives at `~/.bitwarden-ssh-agent.sock` — `exports.zsh` already checks there.

## 7. Validate the risky bits (new silicon)

```sh
inxi -G || lspci -k | grep -A2 VGA   # amdgpu loaded
systemctl suspend                    # lid/suspend
systemctl hibernate                  # resume from the 36G swap partition
fprintd-enroll                       # fingerprint
wpctl status                         # audio sinks present, no phantom devices
fwupdmgr get-devices                 # firmware updates
```

## Iterating after install

```sh
cd ~/.dotfiles/nixos
sudo nixos-rebuild switch --flake .#r2d2   # apply changes
sudo nixos-rebuild boot   --flake .#r2d2   # apply on next boot
# Rollback: pick an older generation in the systemd-boot menu.
```

## Known caveats (this exact hardware)

- **gfx1152 + ROCm**: GPU-compute hang affects `ollama-rocm`; stick to CPU
  `ollama` until fixed. Desktop graphics are unaffected.
- **Module maturity**: `framework-amd-ai-300-series` is a recent clone of the
  7040-series module — suspend needs kernel ≥6.15 (we force latest, so fine).
- **stateVersion**: set in `configuration.nix` to the installing release; never
  bump it on upgrades.
