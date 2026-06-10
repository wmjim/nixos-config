# GTK/Qt 主题包（NixOS 系统层面）
{ pkgs, self, ... }:

{
  environment.systemPackages = with pkgs; [
    xwayland-satellite # XWayland 兼容层（Wayland 环境下运行 X11 应用）

    # GTK 运行时
    gtk4
    gnome-themes-extra # GTK2 Adwaita 主题支持

    # Qt 平台主题：让 Qt 应用自动跟随 GNOME/Adwaita 风格
    qgnomeplatform    # Qt5
    qgnomeplatform-qt6 # Qt6
    adwaita-qt # Qt 的 Adwaita 风格主题

    # 图标和光标（Adwaita）
    papirus-icon-theme # Papirus 图标主题
    bibata-cursors     # Bibata 光标主题
  ];
}
