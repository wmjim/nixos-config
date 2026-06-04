{ config, pkgs, ... }:

{
  imports = [
    ../common/wayland-env.nix
  ];

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


  # KDE 专属环境变量（Wayland 通用变量在 common/wayland-env.nix）
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "KDE";
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
