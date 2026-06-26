# GTK/Qt 主题包（NixOS 系统层面）
{ lib, config, pkgs, self, ... }:
let
  cfg = config.mengw.desktop.common.themes;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.themes.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 GTK/Qt 主题包（系统层面）";
  };

  config = lib.mkIf (cfg.enable && commonCfg.enable && desktopCfg.enable) {
    environment.systemPackages = with pkgs; [
      # XWayland 兼容过程，支持运行 X11 应用
      xwayland-satellite

      # GTK 运行时
      gtk4
      gnome-themes-extra # GTK2 Adwaita 主题支持

      # Qt 平台主题：让 Qt 应用自动跟随 GNOME/Adwaita 风格
      qgnomeplatform # Qt5
      qgnomeplatform-qt6 # Qt6
      adwaita-qt # Qt 的 Adwaita 风格主题

      # 图标和光标（Adwaita）
      papirus-icon-theme # Papirus 图标主题
      bibata-cursors # Bibata 光标主题
    ];
  };
}
