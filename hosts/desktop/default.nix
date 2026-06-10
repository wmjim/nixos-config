# NixOS 台式机配置（完整桌面）
{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    ./hardware.nix
    ./nvidia.nix
    ../../modules/nixos/hardware # 按需选择：可改为按子模块单独导入
    ../../modules/nixos/gui-de
  ];

  # 主机名
  networking.hostName = "desktop";

  # 虚拟化
  virtualisation.libvirtd.enable = true;
  # 启动日志通过 modules/nixos/gui-de/common/boot.nix 配置

  # ==========================================
  # 为 nix-daemon 设置代理 (核心！)
  # ==========================================
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    ftp_proxy = "http://127.0.0.1:7897";
    no_proxy = "localhost,127.0.0.1,local.domain,192.168.0.0/16,bilibili.com,*.bilibili.com";
  };

  # ==========================================
  # 系统级用户会话代理设置 (修正变量名)
  # ==========================================
  environment.sessionVariables = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    ftp_proxy = "http://127.0.0.1:7897";
    no_proxy = "localhost,127.0.0.1,local.domain,192.168.0.0/16,bilibili.com,*.bilibili.com";
  };

  # RDP 防火墙端口
  networking.firewall.allowedTCPPorts = [ 3389 ];
}
