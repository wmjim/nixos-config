# GNOME 桌面环境
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop.gnome;
  desktopCfg = config.mySystem.desktop;
in
{
  config = lib.mkIf (cfg.enable && desktopCfg.enable) {
    # 在64位系统上为 Wine 32 位应用提供 OpenGL
    hardware.graphics.enable32Bit = true;
    # 启用 GNOME 桌面
    services.desktopManager.gnome.enable = true;

    # 默认登录 GNOME 会话
    services.displayManager.defaultSession = "gnome";

    # GDM 登录界面换肤（MacTahoe）：
    # gnome-shell 的 gnome-shell-theme.gresource 路径在编译期烘焙进二进制，
    # 运行时读取的是本包 store 路径下的同名文件，只能通过覆盖 gnome-shell
    # 包替换 gresource（一次重建，代价较高）。用户会话内 user-theme 扩展会
    # 用主题目录里的 shell CSS 再次覆盖，与 base gresource 同为 MacTahoe，
    # 不会冲突。
    nixpkgs.overlays = [
      (final: prev: {
        mactahoe-gtk-theme = prev.callPackage ../../../../pkgs/mactahoe-gtk-theme { };
        mactahoe-icon-theme = prev.callPackage ../../../../pkgs/mactahoe-icon-theme { };
        gnome-shell = prev.gnome-shell.overrideAttrs (old: {
          postFixup = (old.postFixup or "") + ''
            cp ${final.mactahoe-gtk-theme}/share/gnome-shell/gnome-shell-theme.gresource \
              $out/share/gnome-shell/gnome-shell-theme.gresource
          '';
        });
      })
    ];

    # 主题/图标包加入 GDM 的 XDG_DATA_DIRS，登录界面可解析 MacTahoe 资源
    services.displayManager.gdm.extraPackages = [
      pkgs.mactahoe-gtk-theme
      pkgs.mactahoe-icon-theme
    ];

    # 只使用 GNOME 桌面环境而不使用其中的应用程序
    services.gnome.core-apps.enable = false;
    # 安装 GNOME 核心开发者工具
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

      # 彻底禁用空闲自动挂起（与 Niri 行为一致）：
      # 显示器关闭期间系统保持唤醒，避免 NVIDIA 恢复时无法重建
      # 3840x2160@150Hz 自定义模式导致的黑屏（见 8/6 日志 gsd-power-wrap 发起挂起）
      sleep-inactive-ac-timeout=0
      sleep-inactive-ac-type='nothing'
      sleep-inactive-battery-timeout=0
      sleep-inactive-battery-type='nothing'

      # 禁止空闲时激活屏幕保护（可由用户手动锁定）
      [org.gnome.desktop.screensaver]
      idle-activation-enabled=false
    '';

    # 排除部分核心应用
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
      # 插件：加载 shell 主题（MacTahoe 换肤依赖）
      gnomeExtensions.user-themes
    ];
  };
}
