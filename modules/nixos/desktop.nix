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
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "GNOME";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    QT_QPA_PLATFORMTHEME = "gnome";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    # GTK 主题配置
    GTK_THEME = "Adwaita";
  };

  environment.systemPackages = with pkgs; [
    dbus
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    gtk4
    gtk3

    # GNOME 必备
    gnome-control-center    # GNOME 设置应用（关键）
    gnome-tweaks
    gnome-shell-extensions
    adwaita-icon-theme

    clash-verge-rev       # 网络代理
    microsoft-edge        # 浏览器
    vscode                # 代码编辑器
    wechat-uos            # 微信
    qq                    # QQ
    obsidian              # 笔记软件
    thunderbird           # 邮件客户端
  ];
}
