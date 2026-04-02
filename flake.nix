{
  description = "A very basic flake";

  inputs = {
    # 稳定版 nixpkgs（用于系统）
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    # 不稳定版 nixpkgs（用于需要最新版本的包）
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${system};
    in {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; pkgs-unstable = pkgs-unstable; nixvimModule = nixvim.homeModules.default; };
          modules = [
            ./hosts/laptop/configuration.nix
                  home-manager.nixosModules.home-manager
          ];
        };
      };
    };
}
