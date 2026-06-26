# GNOME 桌面环境
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop.gnome;
  desktopCfg = config.mySystem.desktop;
in
{
  config = lib.mkIf (cfg.enable && desktopCfg.enable) {
    services.xserver.enable = true;
    services.desktopManager.gnome.enable = true;

    services.gnome.core-apps.enable = false;
    services.gnome.core-developer-tools.enable = false;
    services.gnome.games.enable = false;

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
    ];
  };
}
