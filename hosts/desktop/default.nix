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
    ../../modules/nixos/proxy
  ];

  # 主机名
  networking.hostName = "desktop";

  # DDC/CI 显示器亮度控制
  hardware.i2c.enable = true;

  # 虚拟化
  virtualisation.libvirtd.enable = true;
  # 启动日志通过 modules/nixos/gui-de/common/boot.nix 配置

  # 代理（通过 modules/nixos/proxy 集中配置）
  proxy.enable = true;
  proxy.extraNoProxy = [ "bilibili.com" "*.bilibili.com" ];
}
