{
  description = "NixOS + macOS 统一配置";

  inputs = {
    # Nixpkgs - 使用 25.11 以匹配 home-manager
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";

    # Home Manager - 使用特定提交避免 mako 模块问题
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nix-darwin (macOS)
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-darwin, home-manager, nix-darwin, ... }@inputs:
    let
      # 使用 nixpkgs lib，不扩展以避免兼容性问题
      lib = nixpkgs.lib;

      # 系统类型（只保留你需要的平台）
      systems = {
        x86_64-linux = "x86_64-linux";    # NixOS 笔记本/服务器
        aarch64-darwin = "aarch64-darwin"; # M系列 Mac
      };

      # 为所有系统生成包
      forAllSystems = lib.genAttrs (lib.attrValues systems);
    in
    {
      # NixOS 配置
      nixosConfigurations = {
        # 笔记本（GNOME 桌面）
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

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.mengw = import ./modules/home;

              # 允许 home-manager 使用非自由软件包
              home-manager.sharedModules = [{
                nixpkgs.config.allowUnfree = true;
              }];
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

            # Home Manager
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = false;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.mengw = import ./modules/home;

              # 允许 home-manager 使用非自由软件包
              home-manager.sharedModules = [{
                nixpkgs.config.allowUnfree = true;
              }];
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
            }
          ];
        };
      };

      # 开发 shell
      devShells = forAllSystems (system:
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
        });

      # 格式化配置
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
