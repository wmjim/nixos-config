# NixOS 笔记本配置（GNOME 桌面）
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/nixos/desktop
    ../../modules/nixos/dev
    ../../modules/nixos/network
  ];

  # 主机名
  networking.hostName = "laptop";

  # 虚拟化
  virtualisation.libvirtd.enable = true;
  boot.kernelParams = [ "console=ttyS0" ];

  # 代理设置（系统级）
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    ftp_proxy = "http://127.0.0.1:7897";
    no_proxy = "localhost,127.0.0.1,local.domain,192.168.0.0/16";
  };

  environment.sessionVariables = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    ftp_proxy = "http://127.0.0.1:7897";
    no_proxy = "localhost,127.0.0.1,local.domain,192.168.0.0/16";
  };

  # RDP 防火墙端口
  networking.firewall.allowedTCPPorts = [ 3389 ];
}
