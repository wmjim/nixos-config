# Distrobox + Podman 容器工具（系统级）
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  options.mySystem.desktop.distrobox.enable = lib.mkEnableOption "Distrobox + Podman 容器工具";

  config = lib.mkIf (cfg.enable && cfg.distrobox.enable) {
    environment.systemPackages = with pkgs; [
      distrobox
      podman
    ];

    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
    };
  };
}
