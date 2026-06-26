# 浏览器
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.apps.browsers;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.browsers.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用浏览器应用";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    home.packages = with pkgs; [
      brave
    ];
  };
}
