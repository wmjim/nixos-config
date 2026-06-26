# 开发工具
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.desktop.common.apps.development;
  appsCfg = config.mengw.desktop.common.apps;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.apps.development.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用开发工具应用";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && commonCfg.enable && desktopCfg.enable) {
    environment.systemPackages = with pkgs; [
      zed-editor # 代码编辑器
    ];
  };
}
