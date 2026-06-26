{ config, pkgs, ... }:

{
  # 启用 X11 服务器
  services.xserver.enable = true;

  # 启用 GNOME 桌面环境
  services.xserver.desktopManager.gnome.enable = true;

  # 禁用安装GNOME全套应用程序仅保留 GNOME shell
  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  # 排除默认情况下随 GNOME 一起安装的某些应用
  environment.gnome.excludePackages = with pkgs; [ 
    gnome-tour 
    gnome-user-docs 
  ];

  # gnome 扩展
  environment.systemPackages = with pkgs; [
    # GNOME 调整工具
    gnome-tweaks
    # dconf 配置编辑器
    dconf-editor
    # 插件：为面板添加模糊效果
    gnomeExtensions.blur-my-shell
    gnomeExtensions.just-perfection
    # 插件：系统托盘图标支持
    gnomeExtensions.appindicator
  ];
}