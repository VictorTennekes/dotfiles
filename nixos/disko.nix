# Declarative whole-disk layout for r2d2 (Framework 13, WD_BLACK SN7100 1TB).
#
#   ⚠️  Applying this ERASES /dev/nvme0n1 entirely (Arch + Void + Fedora + data).
#
# Layout:
#   p1  ESP   1G    vfat   → /boot   (systemd-boot; single OS, roomy ESP)
#   p2  swap  36G          → hibernate target (≥ 32G RAM); resumeDevice=true
#   p3  btrfs rest  ~894G  → @ / @home / @nix / @log / @snapshots (zstd, noatime)
{
  disko.devices.disk.main = {
    type = "disk";
    device = "/dev/nvme0n1";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "1G";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        swap = {
          size = "36G";
          content = {
            type = "swap";
            resumeDevice = true; # sets boot.resumeDevice → enables hibernation
          };
        };

        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@log" = {
                mountpoint = "/var/log";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
              "@snapshots" = {
                mountpoint = "/.snapshots";
                mountOptions = [ "compress=zstd" "noatime" ];
              };
            };
          };
        };
      };
    };
  };
}
