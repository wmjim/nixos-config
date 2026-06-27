# Qt/GTK 手动主题配置（仅 Stylix 禁用时生效）
#
# 当 mySystem.stylix.enable = true 时（当前桌面/笔记本均已启用），
# GTK/Qt/图标/光标/字体全部由 Stylix 统一管理（modules/nixos/core/stylix.nix），
# 本文件所有配置均被跳过。仅作为 Stylix 禁用时的回退方案保留。
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.themes;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.themes.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Qt/GTK 手动主题配置（仅在 Stylix 禁用时生效）";
  };

  # Stylix 启用 → 跳过；Stylix 禁用 → 使用以下手动配置
  config = lib.mkIf (cfg.enable && guiCfg.enable && !(config.stylix.enable or false)) {
    gtk = {
      enable = true;
      theme = { name = "Adwaita"; };
      iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus";
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
