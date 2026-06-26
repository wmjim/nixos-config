# NixOS 服务器（无桌面）
{ config, pkgs, lib, ... }:
{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "server";
}
