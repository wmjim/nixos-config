# niri 窗口管理器配置（搭配 Noctalia Shell）
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # ./noctalia.nix
    ./dms.nix
    ../apps.nix
  ];

  # 使用 niri v26.04（原生模糊效果支持）
  nixpkgs.overlays = [ inputs.niri.overlays.default ];

  # 启用 niri
  programs.niri.enable = true;

  # greetd 由 dms-greeter 模块管理，此处不再重复配置

  # 触控板
  services.libinput.enable = true;

  # Polkit + 密钥环（图形会话需要）
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # XDG portal（Wayland 屏幕共享、文件选择器等）
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.niri = {
      default = [ "gnome" "gtk" ];
    };
  };

  # Wayland / niri 环境变量
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    CLASH_VERGE_ALLOW_CLIPBOARD = "1";
    RUST_BACKTRACE = "1";
    GTK_THEME = "Orchis";
    GTK_ICON_THEME = "WhiteSur";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  # niri 周边工具和主题
  environment.systemPackages = with pkgs; [
    # --- niri 周边 ---
  ];

  # RDP 远程桌面端口
  networking.firewall.allowedTCPPorts = [ 3389 ];
}
