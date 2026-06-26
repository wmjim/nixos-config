# 浏览器
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.desktop.common.apps.browsers;
  appsCfg = config.mengw.desktop.common.apps;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.apps.browsers.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用浏览器应用";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && commonCfg.enable && desktopCfg.enable) {
    environment.systemPackages = with pkgs; [
      brave
    ];
  };
}
