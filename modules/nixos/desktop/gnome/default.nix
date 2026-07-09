# GNOME 桌面环境
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop.gnome;
  desktopCfg = config.mySystem.desktop;
in
{
  config = lib.mkIf (cfg.enable && desktopCfg.enable) {
    services.xserver.enable = true;
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

    # 防止 DP 显示器从 DPMS 熄屏唤醒时黑屏
    # gsd-power 在后台运行，可能触发显示器节能——即使使用 Niri 作为 WM
    # extraGSettingsOverrides 创建 glib override 文件，对所有用户生效
    services.desktopManager.gnome.extraGSettingsOverrides = ''
      # 永不因空闲而激活锁屏/熄屏（idle-delay=0 即禁用空闲检测）
      [org.gnome.desktop.session]
      idle-delay=uint32 0

      # 禁止空闲时降低屏幕亮度
      [org.gnome.settings-daemon.plugins.power]
      idle-dim=false

      # 禁止空闲时激活屏幕保护（可由用户手动锁定）
      [org.gnome.desktop.screensaver]
      idle-activation-enabled=false
    '';

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];

    environment.systemPackages = with pkgs; [
      # GNOME Shell 依赖 ibus-daemon 二进制，即使使用 fcitx5 也需提供
      ibus
      # 软件：扩展管理
      gnome-tweaks
      # 插件：添加毛玻璃模糊效果
      gnomeExtensions.blur-my-shell
      # 插件：深度定制GNOME界面
      gnomeExtensions.just-perfection
      # 插件：应用程序菜单
      gnomeExtensions.arcmenu
      # 插件：将程序启动栏和GNOME面板整合，类似Win
      gnomeExtensions.dash-to-panel
      # 插件：顶部状态栏恢复系统托盘图标
      gnomeExtensions.appindicator
      # 插件：适用于GNOME的输入法面板
      gnomeExtensions.kimpanel
      # 插件：剪贴板管理工具
      gnomeExtensions.clipboard-indicator
      # 插件：窗口关闭神灯动画
      gnomeExtensions.compiz-alike-magic-lamp-effect
      # 插件：Alt+Tab横向3D滚动效果
      gnomeExtensions.coverflow-alt-tab
      # 插件：增强窗口分配
      gnomeExtensions.tiling-shell
      # 插件：为所有窗口添加圆角
      gnomeExtensions.rounded-window-corners-reborn
      # 插件：用于访问和卸载可移动设备的状态菜单
      gnomeExtensions.removable-drive-menu
    ];
  };
}
