# 通讯工具
{ lib, config, pkgs, myLib, ... }:
let
  cfg = config.mengw.gui.apps.communication;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;

  wechat-scaled = myLib.wrapQtXWayland {
    inherit pkgs;
    pkg = pkgs.wechat;
  };
in
{
  options.mengw.gui.apps.communication.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用通讯工具";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    home.packages = with pkgs; [
      discord
      telegram-desktop
      wechat-scaled
      qq
    ];
  };
}
