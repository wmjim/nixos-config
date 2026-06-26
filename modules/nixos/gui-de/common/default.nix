# 通用 GUI/DE 配置（所有桌面环境共享）
{ lib, config, ... }:
let
  cfg = config.mengw.desktop.common;
  parentCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用通用桌面环境配置（应用、环境变量、主题等）";
  };

  imports = [
    ./apps.nix
    ./clash.nix
    ./env.nix
    ./fcitx5.nix
    ./themes.nix
    ./boot.nix
    ./gdm.nix
  ];

  config = lib.mkIf (cfg.enable && parentCfg.enable) {
    # gvfs：Nautilus 回收站、文件挂载、网络共享等功能依赖
    services.gvfs.enable = true;
  };
}
