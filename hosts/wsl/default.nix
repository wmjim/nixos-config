# WSL 主机配置（仅 CLI/TUI）
{ config, pkgs, lib, ... }:

{
  imports = [
    ../_common/wsl/base.nix
    ../_common/nixos/users.nix
    ../_common/nixos/locale.nix
  ];

  # 主机名
  networking.hostName = "wsl";

  # WSL 默认登录用户（nixos-wsl 特有选项）
  wsl.enable = true;
  wsl.defaultUser = "mengw";


  # WSL 根文件系统（占位，安装后替换为实际设备）
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # ==========================================
  # 为 nix-daemon 设置代理 (核心！)
  # ==========================================
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    ftp_proxy = "http://127.0.0.1:7897";
    no_proxy = "localhost,127.0.0.1,local.domain,192.168.0.0/16";
  };

  # ==========================================
  # 系统级用户会话代理设置 (修正变量名)
  # ==========================================
  environment.sessionVariables = {
    http_proxy = "http://127.0.0.1:7897";
    https_proxy = "http://127.0.0.1:7897";
    ftp_proxy = "http://127.0.0.1:7897";
    no_proxy = "localhost,127.0.0.1,local.domain,192.168.0.0/16";
  };
}
