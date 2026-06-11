# NixOS 用户配置
{ config, pkgs, ... }:

{
  users.users.mengw = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "audio"
      "video"
      "input"
      "network"
      "libvirtd"
      "kvm"
      "i2c" # DDC/CI 亮度控制权限
    ];
    shell = pkgs.fish;
  };

  programs.fish.enable = true;
}
