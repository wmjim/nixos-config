# WSL 主机配置（仅 CLI/TUI）
{ config, pkgs, lib, ... }:

{
  imports = [
    ../_common/wsl/base.nix
    ../_common/nixos/users.nix
    ../_common/nixos/locale.nix
    ../../modules/nixos/proxy
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

  # 代理（通过 modules/nixos/proxy 集中配置）
  proxy.enable = true;
}
