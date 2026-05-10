# NixOS 服务器配置（无桌面）
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/cli-tui                # dev + network + server
  ];

  # 主机名
  networking.hostName = "server";
}
