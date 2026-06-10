# GNOME 桌面配置
{ config, pkgs, ... }:

{
  imports = [ ../common/apps.nix ../common/wayland-env.nix ];

  # 显示管理器
  services.displayManager.gdm.enable = true;
  # GNOME 桌面环境
  services.desktopManager.gnome.enable = true;

  # === RDP 远程桌面 ===
  services.gnome.gnome-remote-desktop.enable = true;
  systemd.services.gnome-remote-desktop = {
    # 启动时启用并启动 systemd 单元 
    wantedBy = [ "graphical.target" ];
  };
  services.displayManager.autoLogin.enable = false;
  networking.firewall.allowedTCPPorts = [ 3389 ];


  # GNOME 电源管理 - 合盖不休眠，熄屏不休眠
  systemd.user.services."gnome-power-settings" = {

    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = ''
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/power/lid-close-ac-action "'nothing'"
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-timeout "uint32 0"
        ${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/power/sleep-inactive-ac-type "'nothing'"
      '';
    };
  };

  # RDP 配置 - 防止锁屏断开连接
  systemd.user.services."rdp-settings" = {
    wantedBy = [ "graphical-session.target" ];
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

  # 触控板
  services.libinput.enable = true;

  # GNOME 专属环境变量（Wayland 通用变量在 common/wayland-env.nix）
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "GNOME";
    QT_IM_MODULE = "fcitx";
    GTK_THEME = "WhiteSur-Dark";
    GTK_ICON_THEME = "WhiteSur";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  # 排除的 GNOME 包
  environment.gnome.excludePackages = with pkgs; [
    yelp
    gnome-tour
    gnome-software
    gnome-contacts
    epiphany
    gnome-weather
    gnome-clocks
    gnome-maps
    simple-scan
    totem
    gnome-console
    gedit
    eog
    gnome-calculator
    gnome-screenshot
  ];

  # 额外的 GNOME 应用
  environment.systemPackages = with pkgs; [
    gtk4
    whitesur-gtk-theme
    gnome-text-editor
    gnome-calculator
    gnome-screenshot
    nautilus # 文件管理器
    gnome-tweaks
    gnome-shell-extensions
  ] ++ (with pkgs.gnomeExtensions; [
    user-themes
    hide-top-bar
    clipboard-history
    allow-locked-remote-desktop
    burn-my-windows
    coverflow-alt-tab
    dash-to-panel
    desktop-cube
    just-perfection
    rounded-corners
    rounded-window-corners-reborn
    appindicator
    blur-my-shell
  ]);
}
