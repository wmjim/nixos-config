# NVIDIA 驱动公共基础配置
# 所有使用 NVIDIA GPU 的主机共享此模块，各自覆盖驱动包和 Prime 等特性
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.hardware.nvidia;
  parentCfg = config.mengw.hardware;
in
{
  options.mengw.hardware.nvidia.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 NVIDIA 驱动基础配置";
  };

  config = lib.mkIf (cfg.enable && parentCfg.enable) {
    # Xorg 和 Wayland 的视频驱动配置
    services.xserver.videoDrivers = [ "nvidia" ];

    # Wayland 集成的内核参数
    boot.kernelParams = [
      "nvidia-drm.modeset=1" # Wayland 的模式设置
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1" # 改善睡眠后的恢复
    ];

    # nouveau 黑名单以避免冲突
    boot.blacklistedKernelModules = [ "nouveau" ];

    # 环境变量以提升 Wayland 兼容性
    environment.variables = {
      LIBVA_DRIVER_NAME = "nvidia"; # 硬件视频加速
      GBM_BACKEND = "nvidia-drm"; # Wayland 的图形后端
      __GLX_VENDOR_LIBRARY_NAME = "nvidia"; # GLX 使用 Nvidia 驱动
      __GL_VRR_ALLOWED = "1"; # 启用 VRR（可变刷新率）
      NVD_BACKEND = "direct"; # 新驱动配置
      WLR_NO_HARDWARE_CURSORS = "1"; # 强制软件光标，避免 NVIDIA 光标问题
    };

    # 专有包的配置
    nixpkgs.config = {
      nvidia.acceptLicense = true;
    };

    # Nvidia 基础配置（package 由各主机独立指定）
    hardware = {
      nvidia = {
        open = false; # 闭源驱动以提升性能
        nvidiaSettings = true; # Nvidia 设置工具
        powerManagement.enable = true;
        modesetting.enable = true; # Wayland 必备
        # 注意: package 必须由各主机显式设置
      };

      # 增强的图形支持
      graphics = {
        enable = true;
        enable32Bit = true; # 兼容 Steam/Wine 等 32 位程序
        extraPackages = with pkgs; [
          nvidia-vaapi-driver # 硬件视频加速
          egl-wayland # NVIDIA + Wayland 必须
          libva
        ];
      };
    };

    # niri 的 NVIDIA VRAM 泄漏修复
    # 参考: https://niri-wm.github.io/niri/Nvidia.html
    environment.etc."nvidia/nvidia-application-profiles-rc.d/50-limit-free-buffer-pool-in-wayland-compositors.json" = {
      text = ''
        {
            "rules": [
                {
                    "pattern": {
                        "feature": "procname",
                        "matches": "niri"
                    },
                    "profile": "Limit Free Buffer Pool On Wayland Compositors"
                }
            ],
            "profiles": [
                {
                    "name": "Limit Free Buffer Pool On Wayland Compositors",
                    "settings": [
                        {
                            "key": "GLVidHeapReuseRatio",
                            "value": 0
                        }
                    ]
                }
            ]
        }
      '';
    };

    # CUDA 的 Nix 缓存
    nix.settings = {
      substituters = [ "https://cuda-maintainers.cachix.org" ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };

    # 实用诊断软件包
    environment.systemPackages = with pkgs; [
      vulkan-tools
      mesa-demos
      libva-utils # VA-API debugging tools
    ];
  };
}
