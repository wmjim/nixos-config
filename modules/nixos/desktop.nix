# GUI 桌面环境配置（仅 NixOS）
{ config, pkgs, ... }:

{
  imports = [
    ./terminal/ghostty.nix
    ./fcitx5/fcitx5.nix
  ];

  # GNOME 桌面环境
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GNOME 电源管理 - 合盖不休眠（通过 dconf）
  systemd.user.services."gnome-power-settings" = {
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/power/lid-close-ac-action \"'nothing'\"";
    };
  };

  # 禁用 XDG 用户目录自动创建
  environment.etc."xdg/user-dirs.conf".text = "enabled=False\n";

  # libinput 用于触控板
  services.libinput.enable = true;

  # GTK 环境变量
  # environment.sessionVariables = {
  #   XDG_CURRENT_DESKTOP = "GNOME";
  #   XDG_SESSION_TYPE = "wayland";
  #   GDK_BACKEND = "wayland,x11";
  #   QT_QPA_PLATFORM = "wayland;xcb";
  #   QT_QPA_PLATFORMTHEME = "gnome";
  #   SDL_VIDEODRIVER = "wayland";
  #   CLUTTER_BACKEND = "wayland";
  #   # GTK 主题配置
  #   GTK_THEME = "Adwaita";
  # };

    environment.gnome.excludePackages = with pkgs; [
      # 指定不想安装的官方默认软件（GTK3/旧版应用）
      yelp              # 文档查看器
      gnome-tour        # 新手引导教程
      gnome-software    # 应用商店
      epiphany          # 浏览器（已添加 Microsoft Edge）
      gnome-weather     # 天气
      gnome-clocks      # 时钟
      gnome-maps        # 地图
      simple-scan       # 文档扫描仪
      totem             # 视频播放器
      gnome-console     # 控制台（终端）
      # 旧版 GTK3 应用，用 GTK4 版本替换
      gedit             # 旧版文本编辑器
      eog               # 旧版图片查看器（已添加 gthumb）
      gnome-calculator  # 旧版计算器
      gnome-screenshot  # 旧版截图工具
      nautilus          # 旧版文件管理器
    ];


  environment.systemPackages = with pkgs; [
    # dbus
    # xdg-desktop-portal
    # xdg-desktop-portal-gtk
    # gtk4
    # gtk3

    # GNOME 必备
    # gnome-control-center    # GNOME 设置应用（关键）
    # gnome-tweaks
    # gnome-shell-extensions
    # adwaita-icon-theme

    # 额外的 GNOME 应用（GTK4/libadwaita 现代样式）
    gnome-text-editor     # 文本编辑器（GTK4）
    gnome-calculator      # 计算器（GTK4）
    gnome-screenshot      # 截图工具（GTK4）
    nautilus              # 文件管理器（GTK4）
    gnome-tweaks          # 
    marble-shell-theme    # 主题

    clash-verge-rev       # 网络代理
    microsoft-edge        # 浏览器
    vscode                # 代码编辑器
    wechat-uos            # 微信
    qq                    # QQ
    obsidian              # 笔记软件
    thunderbird           # 邮件客户端
  ] ++ (with gnomeExtensions; [
    appindicator          # 托盘图标支持
    dash-to-dock          # 底部任务栏
    night-theme-switcher  # 自动切换浅色/深色主题
    clipboard-history     # 剪贴板历史
    caffeine              # 禁止屏幕休眠
  ]);
}
