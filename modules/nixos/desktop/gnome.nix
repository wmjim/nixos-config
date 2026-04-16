# GNOME 桌面配置
{ config, pkgs, ... }:

{
  # 显示管理器
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # RDP 远程桌面
  services.gnome.gnome-remote-desktop.enable = true;
  networking.firewall.allowedTCPPorts = [ 3389 ];

  # GNOME 电源管理 - 合盖不休眠
  systemd.user.services."gnome-power-settings" = {
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.dconf}/bin/dconf write /org/gnome/settings-daemon/plugins/power/lid-close-ac-action \"'nothing'\"";
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

  # 环境变量
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "GNOME";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    CLASH_VERGE_ALLOW_CLIPBOARD = "1";
    RUST_BACKTRACE = "1";
    GTK_ICON_THEME = "Adwaita";
  };

  # 排除的 GNOME 包
  environment.gnome.excludePackages = with pkgs; [
    yelp
    gnome-tour
    gnome-software
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
    nautilus
  ];

  # 额外的 GNOME 应用
  environment.systemPackages = with pkgs; [
    gtk4
    adwaita-icon-theme
    gnome-text-editor
    gnome-calculator
    gnome-screenshot
    nautilus
    gnome-tweaks
    gnome-shell-extensions
    tailscale
    # microsoft-edge  # 临时注释，网络恢复后取消注释
    vscode
    obsidian
    thunderbird
  ] ++ (with pkgs.gnomeExtensions; [
    appindicator
    blur-my-shell
    just-perfection
    hide-top-bar
    vitals
    space-bar
    dash-to-dock
    dash-to-panel
    clipboard-history
    caffeine
  ]);
}
