# NVIDIA 驱动 — RTX 3060Ti
{
  config,
  pkgs,
  lib,
  ...
}:

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
    __GL_GSYNC_ALLOWED = "1"; # 如果有G-Sync功能，请启用
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
      open = false; # 闭源驱动以提升性能
      nvidiaSettings = true; # Nvidia 设置工具
      # NVIDIA 电源管理
      powerManagement = {
        enable = true;
      };
      modesetting.enable = true; # Wayland必备
      # 当前架构可用的最新版本-稳定分支
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

    # 增强的图形支持
    graphics = {
      enable = true;
      enable32Bit = true; # 兼容 Steam/Wine 等32位程序
      extraPackages = with pkgs; [
        nvidia-vaapi-driver # 硬件视频加速
        egl-wayland         # NvVIDIA + Wayland 必须
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
