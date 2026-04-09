# 开发工具模块
{ config, pkgs, ... }:

{
  # 虚拟化
  virtualisation.libvirtd.enable = true;
  boot.kernelParams = [ "console=ttyS0" ];

  # Docker（可选）
  # virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    # 开发工具
    lazydocker
    lazygit
  ];
}
