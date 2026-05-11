# NixOS 台式机配置（完整桌面）
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/hardware               # 按需选择：可改为按子模块单独导入
    ../../modules/nixos/gui-de
  ];

  # 主机名
  networking.hostName = "desktop";
}
