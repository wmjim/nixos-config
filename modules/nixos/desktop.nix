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

  # RDP 远程桌面
  services.gnome.gnome-remote-desktop.enable = true;
  networking.firewall.allowedTCPPorts = [ 3389 ];

  # GNOME 电源管理 - 合盖不休眠（通过 dconf）
  systemd.user.services."gnome-power-settings" = {
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      # 合盖不休眠
      ExecStart = "${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/power/lid-close-ac-action \"'nothing'\"";
    };
  };

  # RDP 远程桌面配置 - 防止锁屏断开连接
  systemd.user.services."rdp-settings" = {
    wantedBy = ["graphical-session.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/remote-desktop/rdp/enabled true
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/remote-desktop/vnc/enabled true
        ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/remote-desktop/rdp/ignore-connection true
      '';
    };
  };

  # 禁用 XDG 用户目录自动创建
  environment.etc."xdg/user-dirs.conf".text = "enabled=False\n";

  # libinput 用于触控板
  services.libinput.enable = true;

  # Clash Verge 环境变量（修复 Wayland 剪贴板问题）
  environment.sessionVariables = {
    # Wayland 相关
    XDG_CURRENT_DESKTOP = "GNOME";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    # 允许访问剪贴板
    CLASH_VERGE_ALLOW_CLIPBOARD = "1";
    # 禁用某些可能冲突的功能
    RUST_BACKTRACE = "1";
  };

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
    gedit             # 旧版文本编辑器
    eog               # 旧版图片查看器（已添加 gthumb）
    gnome-calculator  # 旧版计算器
    gnome-screenshot  # 旧版截图工具
    nautilus          # 旧版文件管理器
  ];


  environment.systemPackages = with pkgs; [
    gtk4

    # 额外的 GNOME 应用（GTK4/libadwaita 现代样式）
    gnome-text-editor     # 文本编辑器（GTK4）
    gnome-calculator      # 计算器（GTK4）
    gnome-screenshot      # 截图工具（GTK4）
    nautilus              # 文件管理器（GTK4）
    gnome-tweaks          # 优化
    gnome-shell-extensions# gnome 扩展管理


    clash-verge-rev       # 网络代理
    # v2ray + v2raya        # 备选代理方案
    microsoft-edge        # 浏览器
    vscode                # 代码编辑器
    wechat-uos            # 微信
    qq                    # QQ
    obsidian              # 笔记软件
    thunderbird           # 邮件客户端
  ] ++ (with gnomeExtensions; [
    appindicator          # 托盘图标支持
    blur-my-shell         # ⭐ 毛玻璃效果
    just-perfection       # ⭐ UI 微调神器
    hide-top-bar          # 隐藏顶部面板
    vitals                # 系统监控（CPU/内存）
    space-bar             # 工作区管理增强
    dash-to-dock          # 底部任务栏
    dash-to-panel         # 
    clipboard-history     # 剪贴板历史
    caffeine              # 禁止屏幕休眠
  ]);
}
