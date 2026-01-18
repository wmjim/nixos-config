{
    description = "mengw's dotfiles";
    
    inputs = {
        # 稳定版 nixpkgs（用于系统）
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

        # 不稳定版 nixpkgs（用于需要最新版本的包）
        nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

	      home-manager = {
            url = "github:nix-community/home-manager/release-25.11";
            inputs.nixpkgs.follows = "nixpkgs";
	      };

	      # darwin = {
        #   url = "github:LnL7/nix-darwin";
        #   inputs.nixpkgs.follows = "nixpkgs";
	      # };
	      # vscode-server.url = "github:nix-community/nixos-vscode-server";
    };

    outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }: {
      # NixOS：所有物理机共用这一份配置
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixpkgs-unstable;
        };
        modules = [
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.mengw = {
              imports = [
                ./home/cli-common   # 跨平台 CLI 工具（Arch/NixOS/macOS）
                ./home/nixos-cli    # NixOS 专用 CLI 工具
                ./home/gui          # NixOS GUI 应用
              ];
              home.stateVersion = "25.11";
            };
            home-manager.backupFileExtension = "backup";
          }
        ];
      };

      # macOS
      # darwinConfigurations.mac = darwin.lib.darwinSystem {
      #  system = "x86_64-linux";  # 或 aarch64-darwin
      #  modules = [
      #    ./darwin/default.nix
      #    home-manager.darwinModules.home-manager
      #    {
      #      home-manager.users.mengw = {
      #        imports = [
      #          ./home/common
      #          ./home/gui
      #        ];
      #      };
      #    }
      #  ];
      # };

      # Arch/WSL：纯 Home Manager（CLI only）
      homeConfigurations."mengw@wsl" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          ./home/cli-common   # 跨平台 CLI 工具
          ./wsl/default.nix   # WSL 特定配置
        ];
      };

      # Arch Linux（非 WSL）：纯 Home Manager
      homeConfigurations."mengw@linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [
          ./home/cli-common   # 跨平台 CLI 工具
          ./linux/default.nix # Linux 特定配置
        ];
      };
    };
}
