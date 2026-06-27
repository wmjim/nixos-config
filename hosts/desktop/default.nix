# NixOS 台式机（Niri 桌面）
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
    ./nvidia.nix
  ];

  networking.hostName = "desktop";
  hardware.i2c.enable = true;

  mySystem = {
    hardware.enable = true;
    hardware.nvidia.enable = true;
    desktop.enable = true;
    desktop.gnome.enable = true;
    desktop.niri.enable = true;
    desktop.distrobox.enable = true;
    virtualization.enable = true;
    stylix.enable = true;
    proxy = {
      enable = true;
      extraNoProxy = [ "bilibili.com" "*.bilibili.com" ];
    };
  };
}
