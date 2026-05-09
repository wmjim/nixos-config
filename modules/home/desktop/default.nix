# 桌面环境用户配置
{ config, pkgs, ... }:

{
  imports = [
    ./fcitx5.nix
    ./niri
  ];
}
