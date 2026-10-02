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
    # 4K@150Hz 显示器，整数 2 倍缩放（desktop.scale 由此派生，无需重复声明）
    desktop.monitors = [
      {
        name = "DP-2";
        mode = "3840x2160@150.000";
        scale = 2;
        # 外接显示器走 DDC/CI 调亮度（本机 hardware.i2c.enable = true）
        ddc = true;
      }
    ];
    # 其余桌面能力（niri/distrobox/virtualization/proxy）由 desktop 域
    # 聚合默认值给出，此处只留与 laptop 的真实差异
    desktop.steam.enable = true;
  };
}
