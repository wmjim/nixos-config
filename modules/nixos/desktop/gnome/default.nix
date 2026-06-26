# GNOME 桌面环境
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop.gnome;
  desktopCfg = config.mySystem.desktop;
in
{
  config = lib.mkIf (cfg.enable && desktopCfg.enable) {
    # services.xserver.enable = true;
    services.desktopManager.gnome.enable = true;

    services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;

    services.gnome.gnome-keyring.enable = true;
    services.gnome.core-os-services.enable = true;
    services.gnome.core-shell.enable = true;

    # XDG 桌面门户（Niri 模块设置了 enable + extraPortals，此处仅补 GNOME 专属配置）
    xdg.portal.config.gnome = lib.mkDefault {
      default = "gnome;gtk";
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      dconf-editor
      # 插件：添加毛玻璃模糊效果
      gnomeExtensions.blur-my-shell
      # 插件：深度定制GNOME界面
      gnomeExtensions.just-perfection
      # 插件：顶部面板中的程序停靠栏
      gnomeExtensions.dash-in-panel
      # 插件：顶部状态栏恢复系统托盘图标
      gnomeExtensions.appindicator
      # 插件：平铺式窗口管理器
      gnomeExtensions.paperwm
      # 插件：适用于GNOME的输入法面板
      gnomeExtensions.kimpanel
      # 插件：用户自定义 shell 主题
      gnomeExtensions.user-themes
      # 插件：剪贴板管理工具
      gnomeExtensions.clipboard-indicator
      # 插件：窗口关闭神灯动画
      gnomeExtensions.compiz-alike-magic-lamp-effect
      # 插件：Alt+Tab横向3D滚动效果
      gnomeExtensions.coverflow-alt-tab
      # 插件：炫酷地让窗口消散
      gnomeExtensions.burn-my-windows
      # 插件：增强窗口分配
      gnomeExtensions.tiling-shell
      # 插件：为所有窗口添加圆角
      gnomeExtensions.rounded-window-corners-reborn
    ];
  };
}
