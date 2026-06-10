# NVIDIA 驱动 — MX150 (Pascal) 需使用 580.x Legacy 分支
{ config, pkgs, lib, ... }:

{

  # Xorg 和 Wayland 的视频驱动配置
  # 简化版——其他模块会自动加载
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # Wayland和Hyprland集成的内核参数
  boot.kernelParams = [
    "nvidia-drm.modeset=1"  # Wayland 的启用模式设置
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"   # 改善睡眠后的恢复
  ];

  # nouveau 黑名单以避免冲突
  boot.blacklistedKernelModules = ["nouveau"];

  # 环境变量以提升兼容性
  environment.variables = {
    LIBVA_DRIVER_NAME = "nvidia"; # 硬件视频加速
    GBM_BACKEND = "nvidia-drm"; # Wayland 的图形后端
    __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # GLX使用Nvidia驱动
    NIXOS_OZONE_WL = "1"; # Edge/Chrome/Electron 的 Wayland 支持
    __GL_VRR_ALLOWED = "1"; # 启用VRR（可变刷新率）
    NVD_BACKEND = "direct"; # 新驱动配置
    WLR_NO_HARDWARE_CURSORS = "1";  # 强制软件光标，避免 NVIDIA 光标问题
  };

  # 专有包的配置
  nixpkgs.config = {
    nvidia.acceptLicense = true;
  };

  # Nvidia配置
  hardware = {
    nvidia = {
      open = false; # MX150 不支持开源驱动，使用闭源驱动
      nvidiaSettings = true; # Nvidia 设置工具
      # NVIDIA 电源管理
      powerManagement = {
        enable = true;
        finegrained = true; # 更精准的功耗控制
      };
      modesetting.enable = true; # Wayland必备
      # 锁定 580.x Legacy 驱动
      package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

      # 混合iGPU+dGPU笔记本的配置
      prime = {
        # 可切换显卡笔记本优化配置
        offload = {
          # 为节能优化的模式
          enable = true; # 卸载模式: 让 iGPU 处理所有任务，dGPU 进入睡眠模式
          enableOffloadCmd = true; # 允许运行专用GPU的应用程序
        };
        # 关闭同步启用模式，因为卸载模式通常对笔记本更好
        sync.enable = false;
        # 已为你的硬件验证的 PCI ID 
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };

    # 增强的图形支持
    graphics = {
      enable = true;
      enable32Bit = true; # 兼容 Steam/Wine 等32位程序
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        egl-wayland
        libva
      ];
    };
  };

  # CUDA 的 Nix 缓存
  nix.settings = {
    substituters = ["https://cuda-maintainers.cachix.org"];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };
  
  # 其他实用软件包
  environment.systemPackages = with pkgs; [
    vulkan-tools
    mesa-demos
    libva-utils # VA-API debugging tools
  ];
}
