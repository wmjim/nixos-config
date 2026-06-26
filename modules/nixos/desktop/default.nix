# 桌面环境系统级模块（GDM、环境变量、窗口管理器）
# 仅在 mySystem.desktop.enable = true 时生效
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  options.mySystem.desktop.niri.enable = lib.mkEnableOption "Niri 窗口管理器";
  options.mySystem.desktop.gnome.enable = lib.mkEnableOption "GNOME 桌面环境";

  imports = [
    ./boot.nix
    ./gdm.nix
    ./env.nix
    ./niri
    ./gnome
    ./distrobox.nix
  ];

  config = lib.mkIf cfg.enable {
    # gvfs：文件管理、回收站、网络共享
    services.gvfs.enable = true;

    # 输入法（系统层面）
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          kdePackages.fcitx5-chinese-addons
          kdePackages.fcitx5-configtool
          kdePackages.fcitx5-qt
          fcitx5-gtk
          fcitx5-mellow-themes
          (fcitx5-rime.override {
            rimeDataPkgs = [ pkgs.rime-wanxiang ];
          })
        ];
      };
    };

    # 确保 fcitx5 在登录时自动启动
    services.xserver.desktopManager.runXdgAutostartIfNone = true;

    # 输入法环境变量
    environment.sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      QT_IM_MODULE = "fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "ibus";
      NIXOS_OZONE_WL = "1";
    };

    # Clash Verge 代理客户端
    programs.clash-verge = {
      enable = true;
      autoStart = true;
      serviceMode = true;
    };

    # GTK/Qt 主题包
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      gtk4
      gnome-themes-extra
      qgnomeplatform
      qgnomeplatform-qt6
      adwaita-qt
      papirus-icon-theme
      bibata-cursors
    ];
  };
}
