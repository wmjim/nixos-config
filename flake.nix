{
  description = "NixOS + macOS 统一配置";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nur,
      noctalia,
      nixpkgs-darwin,
      home-manager,
      nixos-wsl,
      nix-darwin,
      ...
    }@inputs:
    let
      lib = nixpkgs.lib;
      myLib = import ./lib { inherit lib; };

      # Home Manager 共享样板：减少每个主机的重复代码
      mkHomeManager =
        { extraModules ? [ ] }:
        { config, ... }:
        {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-bak";
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.mengw.imports = [
            ./modules/home-manager
          ] ++ extraModules;
          home-manager.sharedModules = [
            { nixpkgs.config.allowUnfree = true; }
          ];
        };

      # 所有 NixOS 主机共享的核心模块
      nixosCore = [
        ./modules/nixos/core
        home-manager.nixosModules.home-manager
      ];
    in
    {
      # ==========================================
      # NixOS 配置
      # ==========================================
      nixosConfigurations = {
        # 台式机（Niri 桌面）
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs lib; };
          modules = nixosCore ++ [
            ./hosts/desktop
            (mkHomeManager { extraModules = [ ./modules/home-manager/gui ]; })
          ];
        };

        # 笔记本（GNOME 桌面）
        laptop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs lib; };
          modules = nixosCore ++ [
            ./hosts/laptop
            (mkHomeManager { extraModules = [ ./modules/home-manager/gui ]; })
          ];
        };

        # WSL（仅 CLI/TUI）
        wsl = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs lib; };
          modules = nixosCore ++ [
            ./hosts/wsl
            (mkHomeManager { })
          ];
        };

        # 服务器（无桌面）
        server = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs lib; };
          modules = nixosCore ++ [
            ./hosts/server
            (mkHomeManager { })
          ];
        };
      };

      # ==========================================
      # macOS 配置
      # ==========================================
      darwinConfigurations = {
        macbook = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs lib; };
          modules = [
            ./hosts/_common/darwin/base.nix
            ./hosts/_common/darwin/users.nix
            ./hosts/macbook

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.mengw = {
                nixpkgs.overlays = lib.mkForce [ ];
                imports = [ ./modules/home-manager ];
              };
              home-manager.sharedModules = [ ];
            }
          ];
        };
      };

      # ==========================================
      # 开发 Shell
      # ==========================================
      devShells = myLib.forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              nixpkgs-fmt
            ];
          };
        }
      );

      # 格式化配置
      formatter = myLib.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
