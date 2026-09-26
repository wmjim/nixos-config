# NixOS 台式机（Niri 桌面）
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
    ./edid-reprobe.nix
  ];

  networking.hostName = "desktop";
  hardware.i2c.enable = true;

  mySystem = {
    hardware.enable = true;
    hardware.nvidia.enable = true;
    desktop.enable = true;
    # 4K@150Hz 显示器，分数缩放 1.5（desktop.scale 由此派生，无需重复声明）
    desktop.monitors = [
      {
        name = "DP-2";
        mode = "3840x2160@150.000";
        scale = 1.5;
        focus = true;
        # 外接显示器走 DDC/CI 调亮度（本机 hardware.i2c.enable = true）
        ddc = true;
      }
    ];
    desktop.gnome.enable = true;
    desktop.niri.enable = true;
    desktop.distrobox.enable = true;
    desktop.steam.enable = true;
    virtualization.enable = true;
    proxy.enable = true;
    # Windows 客户机（WinApps）经网桥地址 192.168.122.1 使用宿主代理
    proxy.exposeToVms = true;
  };
}
