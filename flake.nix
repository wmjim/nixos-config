{
  description = "A very basic flake";

  inputs = {
    # 默认使用 nixos-unstable 分支
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # 最新 stable 分支的 nixpkgs，用于回退个别软件包的版本
    # nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.11";

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
