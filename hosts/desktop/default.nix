# NixOS 台式机（Niri 桌面）
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
    ./nvidia.nix
    ./edid-reprobe.nix
  ];

  networking.hostName = "desktop";
  hardware.i2c.enable = true;

  mySystem = {
    hardware.enable = true;
    hardware.nvidia.enable = true;
    desktop.enable = true;
    # 4K@150Hz 显示器，GNOME/Niri 分数缩放 1.5
    desktop.scale = 1.5;
    desktop.gnome.enable = true;
    desktop.niri.enable = true;
    desktop.distrobox.enable = true;
    desktop.steam.enable = true;
    virtualization.enable = true;
    proxy.enable = true;
  };
}
