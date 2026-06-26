# GNOME 桌面环境
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop.gnome;
  desktopCfg = config.mySystem.desktop;
in
{
  config = lib.mkIf (cfg.enable && desktopCfg.enable) {
    # services.xserver.enable = true;
    services.desktopManager.gnome.enable = true;

    services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;

    services.gnome.gnome-keyring.enable = true;
    services.gnome.core-os-services.enable = true;
    services.gnome.core-shell.enable = true;

    # XDG 桌面门户（Niri 模块设置了 enable + extraPortals，此处仅补 GNOME 专属配置）
    xdg.portal.config.gnome = lib.mkDefault {
      default = "gnome;gtk";
    };

    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];

    environment.systemPackages = with pkgs; [
      gnome-tweaks
      dconf-editor
      gnomeExtensions.blur-my-shell
      gnomeExtensions.just-perfection
      gnomeExtensions.appindicator
      # 插件：平铺式窗口管理器
      gnomeExtensions.paperwm
      # 插件：输入法
      gnomeExtensions.kimpanel
    ];
  };
}
