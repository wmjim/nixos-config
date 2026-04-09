# NixOS 服务器配置（无桌面）
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/dev
    ../../modules/nixos/network
    ../../modules/nixos/server
  ];

  # 主机名
  networking.hostName = "server";

  # 服务器特定配置
  # 无桌面环境
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;

  # 服务器防火墙端口（示例）
  # networking.firewall.allowedTCPPorts = [ 80 443 8080 ];

  # 服务器服务
  # services.nginx.enable = true;
  # services.postgresql.enable = true;
}
