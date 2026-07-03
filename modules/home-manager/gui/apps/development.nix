# 开发工具
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.apps.development;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.development.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用开发工具应用";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    home.packages = with pkgs; [
      zed-editor
      jetbrains.clion
    ];
  };
}
