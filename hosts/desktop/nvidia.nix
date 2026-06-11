# NVIDIA 驱动 — RTX 3060Ti
{ config, pkgs, lib, ... }:

{
  imports = [ ../../modules/nixos/hardware/nvidia-base.nix ];

  # 桌面平台专属: G-Sync / VRR
  environment.variables = {
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
  };

  hardware.nvidia = {
    # 当前架构可用的最新版本 - 稳定分支
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    # 桌面显卡电源管理
    powerManagement.enable = true;
  };
}
