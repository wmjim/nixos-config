# niri 窗口管理器配置（搭配 Noctalia Shell）
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # ./noctalia.nix
    ./dms.nix
    ../common/apps.nix
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
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    CLASH_VERGE_ALLOW_CLIPBOARD = "1";
    RUST_BACKTRACE = "1";
    GTK_THEME = "Adapta-Nokto";
    GTK_ICON_THEME = "WhiteSur";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  # RDP 远程桌面端口
  networking.firewall.allowedTCPPorts = [ 3389 ];

  # niri-sidebar: 轻量侧边栏管理器，可将窗口收入/移出屏幕侧边的浮动堆叠栏
  environment.systemPackages = [
    (pkgs.rustPlatform.buildRustPackage rec {
      pname = "niri-sidebar";
      version = "unstable-2025-06-09";
      src = pkgs.fetchFromGitHub {
        owner = "Vigintillionn";
        repo = "niri-sidebar";
        rev = "954f62e7e395ae14f01af582296e25a548133dc0";
        hash = "sha256-MYP1ZiwV9+yJhl0zpuri6NQkQHlaYZjGBhXpZEaPZyI=";
      };
      cargoHash = "sha256-zZlfwAxWE1ZZy6k7QoBOamCGigGShd89sD27vfvgR00=";
    })
  ];
}
