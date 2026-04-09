# NixOS 用户配置
{ config, pkgs, ... }:

{
  users.users.mengw = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "input" "network" "libvirtd" "kvm" ];
    shell = pkgs.fish;
    packages = [];
  };

  programs.fish.enable = true;
}
