# Qt/GTK 统一主题配置（Adwaita）
# 参考: https://wiki.archlinux.org/title/Uniform_look_for_Qt_and_GTK_applications
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.themes;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.themes.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Qt/GTK 统一主题配置（Adwaita）";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    # --- GTK 主题 (via home-manager, 生成 settings.ini) ---
    gtk = {
    enable = true;
    # 样式主题：Adwaita（GNOME 默认主题，GTK3/4 内置）
    theme = {
      name = "Adwaita";
    };
    # 图标主题
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus";
    };
    # 光标主题
    cursorTheme = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };
    # 字体
    font = {
      name = "HarmonyOS Sans SC";
      size = 12;
    };
  };

  # --- Qt 主题：通过 QGnomePlatform 自动跟随 GTK/Adwaita ---
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
