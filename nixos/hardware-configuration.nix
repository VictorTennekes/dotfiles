# Minimal hardware profile for r2d2 (Framework 13 AMD / Ryzen AI 7 350).
#
# Filesystems and swap are owned by ./disko.nix, so this file deliberately
# does NOT declare fileSystems. After booting the installer and running disko,
# regenerate the precise module list for this exact unit with:
#
#   sudo nixos-generate-config --no-filesystems --root /mnt
#
# then replace this file with /mnt/etc/nixos/hardware-configuration.nix.
# The values below are sane defaults for this NVMe + AMD laptop and will boot.
{ config, lib, pkgs, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "thunderbolt"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  hardware.cpu.amd.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.enableRedistributableFirmware = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
