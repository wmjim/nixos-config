# niri 窗口管理器配置（搭配 Noctalia Shell）
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./noctalia.nix
    # ./dms.nix
    ../common/apps.nix
    ../common/wayland-env.nix
  ];

  # 启用 niri
  programs.niri.enable = true;

  # 触控板
  services.libinput.enable = true;

  # Polkit + 密钥环（图形会话需要）
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # dconf 数据库（GNOME/GTK 应用读取配置必需）
  programs.dconf.enable = true;

  # XDG portal（Wayland 屏幕共享、文件选择器等）
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      # KDE port 后端
      kdePackages.xdg-desktop-portal-kde
    ];
    config.niri = {
      default = lib.mkForce "gnome;gtk;kde";
    };
  };

  # niri 专属环境变量（Wayland 通用变量在 common/wayland-env.nix）
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
  };

  # RDP 远程桌面端口
  networking.firewall.allowedTCPPorts = [ 3389 ];
}
