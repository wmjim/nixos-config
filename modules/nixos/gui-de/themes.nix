# GTK/Qt 主题包（NixOS 系统层面）
{ pkgs, ... }:

{
  # 将 KDE/Qt 主题目录加入系统 profile（默认白名单不含这些路径）
  environment.pathsToLink = [
    "/share/Kvantum"
    "/share/aurorae"
    "/share/color-schemes"
    "/share/plasma"
  ];

  environment.systemPackages = with pkgs; [
    # GTK 主题
    gtk4                              # GTK4 运行时
    adapta-gtk-theme                  # Adapta GTK 主题（GTK 3/4）
    gnome-themes-extra                # GTK 主题引擎

    # Qt 主题工具
    qt6Packages.qt6ct                 # Qt6 主题配置工具
    libsForQt5.qt5ct                  # Qt5 主题配置工具
    qt6Packages.qtstyleplugin-kvantum # Kvantum 主题引擎 Qt6
    libsForQt5.qtstyleplugin-kvantum  # Kvantum 主题引擎 Qt5

    # KDE/Kvantum 主题
    adapta-kde-theme                  # Adapta KDE 主题（Kvantum + Aurorae + 颜色方案）

    # 图标和光标
    whitesur-icon-theme               # WhiteSur 图标主题
    bibata-cursors                    # Bibata 光标主题
  ];
}
