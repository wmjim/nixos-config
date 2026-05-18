{
  description = "NixOS + macOS 统一配置";

  inputs = {
    # Nixpkgs - 使用 25.11 以匹配 home-manager
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    nur.url = "github:nix-community/NUR";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # niri 26.04 — 原生模糊效果支持
    niri = {
      url = "github:YaLTeR/niri/v26.04";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # wsl
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin (macOS)
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nur,
      dms-plugin-registry,
      noctalia,
      niri,
      nixpkgs-darwin,
      home-manager,
      nixos-wsl,
      nix-darwin,
      nixvim,
      ...
    }@inputs:
    let
      # 使用 nixpkgs lib，不扩展以避免兼容性问题
      lib = nixpkgs.lib;

      # 系统类型（只保留你需要的平台）
      systems = {
        x86_64-linux = "x86_64-linux"; # NixOS 笔记本/服务器
        aarch64-darwin = "aarch64-darwin"; # M系列 Mac
      };

      # 为所有系统生成包
      forAllSystems = lib.genAttrs (lib.attrValues systems);
    in
    {
      # NixOS 配置
      nixosConfigurations = {
        # 笔记本（完整桌面）
        laptop = nixpkgs.lib.nixosSystem {
          system = systems.x86_64-linux;
          specialArgs = { inherit inputs lib; };
          modules = [
            # 基础配置
            ./hosts/_common/nixos/base.nix
            ./hosts/_common/nixos/users.nix
            ./hosts/_common/nixos/locale.nix
            # 主机特定配置
            ./hosts/laptop

            # Home Manager（CLI/TUI + GUI/DE）
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.mengw = {
                imports = [
                  # 基础 CLI 环境
                  ./modules/home
                  # 扩展 GUI+DE
                  ./modules/home/gui-de
                ];
              };

              # 允许 home-manager 使用非自由软件包；注入 nixvim 模块
              home-manager.sharedModules = [
                inputs.nixvim.homeModules.nixvim
                { nixpkgs.config.allowUnfree = true; }
              ];
            }
          ];
        };

        # 服务器（无桌面）
        server = nixpkgs.lib.nixosSystem {
          system = systems.x86_64-linux;
          specialArgs = { inherit inputs lib; };
          modules = [
            # 基础配置
            ./hosts/_common/nixos/base.nix
            ./hosts/_common/nixos/users.nix
            ./hosts/_common/nixos/locale.nix

            # 主机特定配置
            ./hosts/server

            # Home Manager（仅 CLI/TUI）
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = { inherit inputs; };
              # 基础 CLI 环境
              home-manager.users.mengw = import ./modules/home;

              # 允许 home-manager 使用非自由软件包；注入 nixvim 模块
              home-manager.sharedModules = [
                inputs.nixvim.homeModules.nixvim
                { nixpkgs.config.allowUnfree = true; }
              ];
            }
          ];
        };

        # 台式机（完整桌面）
        desktop = nixpkgs.lib.nixosSystem {
          system = systems.x86_64-linux;
          specialArgs = { inherit inputs lib; };
          modules = [
            # 基础配置
            ./hosts/_common/nixos/base.nix
            ./hosts/_common/nixos/users.nix
            ./hosts/_common/nixos/locale.nix

            # 主机特定配置
            ./hosts/desktop

            # Home Manager（CLI/TUI + GUI/DE）
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.mengw = {
                imports = [
                  # 基础 CLI 环境
                  ./modules/home
                  # 扩展 GUI+DE
                  ./modules/home/gui-de
                ];
              };

              # 允许 home-manager 使用非自由软件包；
              home-manager.sharedModules = [
                # 注入 nixvim 模块
                inputs.nixvim.homeModules.nixvim
                { nixpkgs.config.allowUnfree = true; }
              ];
            }
          ];
        };

        # WSL（仅 CLI/TUI）
        wsl = nixpkgs.lib.nixosSystem {
          system = systems.x86_64-linux;
          specialArgs = { inherit inputs lib; };
          modules = [
            # 通过 Flake 引入 WSL 模块
            inputs.nixos-wsl.nixosModules.default
            # 主机特定配置（WSL 有自己的 base，不走 _common/nixos）
            ./hosts/wsl

            # Home Manager（仅 CLI/TUI）
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "hm-bak";
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.mengw = import ./modules/home;

              # 允许 home-manager 使用非自由软件包；注入 nixvim 模块
              home-manager.sharedModules = [
                inputs.nixvim.homeModules.nixvim
                { nixpkgs.config.allowUnfree = true; }
              ];
            }
          ];
        };
      };

      # macOS 配置
      darwinConfigurations = {
        macbook = nix-darwin.lib.darwinSystem {
          system = systems.aarch64-darwin;
          specialArgs = { inherit inputs lib; };
          modules = [
            # 基础配置
            ./hosts/_common/darwin/base.nix
            ./hosts/_common/darwin/users.nix

            # 主机特定配置
            ./hosts/macbook

            # Home Manager
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs lib; };
              home-manager.users.mengw = import ./modules/home;
              home-manager.sharedModules = [
                inputs.nixvim.homeModules.nixvim
              ];
            }
          ];
        };
      };

      # 开发 shell
      devShells = forAllSystems (
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
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
