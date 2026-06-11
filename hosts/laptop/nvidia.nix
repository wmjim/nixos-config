# NVIDIA 驱动 — MX150 (Pascal) 需使用 580.x Legacy 分支
{ config, ... }:

{
  imports = [ ../../modules/nixos/hardware/nvidia-base.nix ];

  hardware.nvidia = {
    # 锁定 580.x Legacy 驱动
    package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    # 笔记本精细功耗控制
    powerManagement = {
      enable = true;
      finegrained = true;
    };

    # 混合 iGPU + dGPU 笔记本配置
    prime = {
      offload = {
        enable = true; # 卸载模式: iGPU 处理一切，dGPU 休眠
        enableOffloadCmd = true; # 允许按需启动 dGPU 应用
      };
      sync.enable = false;
      # 已验证的 PCI ID
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}
