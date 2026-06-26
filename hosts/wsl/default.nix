# WSL 主机（仅 CLI/TUI）
{ config, pkgs, lib, inputs, ... }:
{
  imports = [
    inputs.nixos-wsl.nixosModules.default
  ];

  networking.hostName = "wsl";

  # WSL 容器模式，不需要 bootloader
  boot.isContainer = true;

  # WSL 默认用户
  wsl.enable = true;
  wsl.defaultUser = "mengw";

  # 根文件系统
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  mySystem = {
    proxy.enable = true;
  };
}
