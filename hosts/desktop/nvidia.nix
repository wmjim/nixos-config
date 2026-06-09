# NVIDIA 驱动 — RTX 3060Ti
{
  config,
  pkgs,
  lib,
  ...
}:

{
  hardware.graphics = {
    enable = true;      
    enable32Bit = true;    # 兼容 Steam/Wine 等32位程序
  };

  # 已启用视频驱动程序
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [
    "nvidia-drm.modeset=1"  # wayland 能跑基础
    "nvidia-drm.fbdev=1"    # 可选：开启模拟层
  ];

  hardware.nvidia = {
    open = true;  # 开源内核模块
    # 内核模式设置KMS(Wayland支持)
    modesetting.enable = true;
    # 当前架构可用的最新版本-稳定分支
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
