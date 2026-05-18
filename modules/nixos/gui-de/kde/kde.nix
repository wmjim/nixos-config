{ config, pkgs, ... }:

{
  # 启用 Plasma 桌面
  services.desktopManager.plasma6.enable = true;

  # Plasma的默认显示管理器
  services.displayManager.gdm.enable = true;

  # 启用 xserver
  services.xserver.enable = true;

  # KRDP 远程桌面
  networking.firewall.allowedTCPPorts = [ 3389 ];

  # 系统级 krdpserverrc 配置
  environment.etc."xdg/krdpserverrc".text = ''
    [General]
    Certificate=/etc/krdp/krdp.crt
    CertificateKey=/etc/krdp/krdp.key
    SystemUserEnabled=true
  '';


  # KDE 会话环境变量
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "KDE";
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

  # 从默认安装中排除应用程序
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    plasma-browser-integration
    konsole
    elisa
  ];
}