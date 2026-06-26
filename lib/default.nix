# 自定义函数库
# 提供跨模块共享的工具函数，避免重复代码
{ lib }:
{
  # 为所有支持的平台生成属性集
  # 用法: forAllSystems (system: pkgs: ...)
  forAllSystems = lib.genAttrs [
    "x86_64-linux"
    "aarch64-darwin"
  ];

  # Home Manager 共享配置片段
  # 减少 flake.nix 中每个主机的 home-manager 样板代码
  # 用法: mkHomeManager { inputs = inputs; extraModules = [ ./gui ]; }
  mkHomeManager =
    { inputs
    , extraModules ? [ ]
    }:
    { config, ... }:
    {
      home-manager.useGlobalPkgs = false;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "hm-bak";
      home-manager.extraSpecialArgs = { inherit inputs; };
      home-manager.users.mengw.imports = [
        ../../modules/home-manager
      ] ++ extraModules;
      home-manager.sharedModules = [
        { nixpkgs.config.allowUnfree = true; }
      ];
    };
}
