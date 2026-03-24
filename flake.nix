{
  description = "A very basic flake";

  inputs = {
    # 清华大学镜像
    # nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-25.11";
    # 稳定版 nixpkgs（用于系统）
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # 不稳定版 nixpkgs（用于需要最新版本的包）
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      # If you are not running an unstable channel of nixpkgs, select the corresponding branch of Nixvim.
      # url = "github:nix-community/nixvim/nixos-25.11";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    # noctalia-shell
    # noctalia = {
    #   url = "github:noctalia-dev/noctalia-shell";
    #   inputs.nixpkgs.follows = "nixpkgs-unstable";
    # };
  };

  outputs = { self, nixpkgs, home-manager, nixvim, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
	  inherit system;
	  specialArgs = { inherit inputs; };
	  modules = [
	    ./hosts/laptop/configuration.nix
            home-manager.nixosModules.home-manager
            nixvim.nixosModules.nixvim
	  ];
	};
      };
    };
}
