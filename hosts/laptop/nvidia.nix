# NVIDIA 驱动 — MX150 (Pascal) 需使用 580.x Legacy 分支
{ config, pkgs, lib, ... }:

{
  hardware.graphics.enable = true;

  # KMS + fbdev: Wayland 合成器（niri）模糊效果 / PRIME 正常工作所需
  boot.kernelParams = [ "nvidia-drm.modeset=1" "nvidia-drm.fbdev=1" ];
  
  # 已启用视频驱动程序
  services.xserver.videoDrivers = [ 
    "nvidia"
  ];

  hardware.nvidia = {
    open = false; # MX150 不支持开源驱动，使用闭源驱动
    # 内核模式设置KMS(Wayland支持)
    modesetting.enable = true;
    # 卸载模式: 让 iGPU 处理所有任务，dGPU 进入睡眠模式
    prime.offload.enable = true;
    # 同步模式：渲染完全委托 的GPU
    # 更高的功耗
    # prime.sync.enable = true;
    prime.intelBusId = "PCI:0:2:0";
    prime.nvidiaBusId = "PCI:1:0:0";
    # 锁定 580.x Legacy 驱动
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
}
