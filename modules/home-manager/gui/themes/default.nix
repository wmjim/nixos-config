# Qt/GTK 主题配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.themes;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.themes.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Qt/GTK 主题配置";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    gtk = {
      enable = true;
      theme = { name = "Adwaita"; };
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };
      font = {
        name = "HarmonyOS Sans SC";
        size = 12;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style = {
        package = pkgs.adwaita-qt;
        name = "adwaita";
      };
    };
  };
}
