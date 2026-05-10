# NVIDIA 驱动 — MX150 (Pascal) 需使用 580.x Legacy 分支
{ config, pkgs, lib, ... }:

{
  hardware.graphics.enable = true;

  hardware.nvidia = {
    open = false;                   # MX150 不支持开源驱动，使用闭源驱动
    modesetting.enable = true;
    powerManagement.enable = true;
    prime.offload.enable = false;   # 保持 dGPU 关闭以省电
    # 锁定 580.x Legacy 驱动
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
}
