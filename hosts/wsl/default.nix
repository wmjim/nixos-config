# WSL 主机配置（仅 CLI/TUI）
{ config, pkgs, lib, ... }:

{
  imports = [
    ../_common/wsl/base.nix
    ../_common/nixos/users.nix
    ../_common/nixos/locale.nix
    ../../modules/nixos/cli-tui
  ];

  # 主机名
  networking.hostName = "wsl";

  # WSL 根文件系统（占位，安装后替换为实际设备）
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
}
