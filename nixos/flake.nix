{
  description = "r2d2 — Framework 13 AMD (Ryzen AI 7 350) NixOS configuration";

  inputs = {
    # Unstable: the Zen5 / Krackan Point (gfx1152) silicon is new enough that
    # it wants a recent kernel + Mesa. Stable can lag the hardware.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Declarative whole-disk partitioning — the disk layout is code.
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Zen browser — not in nixpkgs proper.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # fetch — spins the distro logo in 3D with live system info; reuses
    # fastfetch's logos. Not in nixpkgs; consumed as a plain package (we
    # don't run Home Manager, so its HM module is unused).
    areofyl-fetch = {
      url = "github:areofyl/fetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixos-hardware, disko, ... }: {
    nixosConfigurations.r2d2 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        nixos-hardware.nixosModules.framework-amd-ai-300-series
        disko.nixosModules.disko
        ./disko.nix
        ./hardware-configuration.nix
        ./configuration.nix
      ];
    };
  };
}
