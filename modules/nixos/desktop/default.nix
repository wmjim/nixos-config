# 桌面环境模块
{ config, pkgs, ... }:

{
  imports = [
    ./gnome.nix
    ./fcitx5.nix
  ];
}
