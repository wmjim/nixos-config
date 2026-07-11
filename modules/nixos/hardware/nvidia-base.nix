# NVIDIA 驱动公共基础配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.hardware;
in
{
  options.mySystem.hardware.nvidia.enable = lib.mkEnableOption "NVIDIA 驱动";

  config = lib.mkIf (cfg.enable && cfg.nvidia.enable) {
    services.xserver.videoDrivers = [ "nvidia" ];

    boot.kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_TemporaryFilePath=/var/tmp"
      "nvidia.NVreg_UseKernelSuspendNotifiers=1"
      # 完全禁用动态电源管理。即使设为 0x01（细粒度模式），显示器断开/
      # 休眠后 DP 链路唤醒时 GPU 仍无法正确重新训练 DP 链路，导致黑屏。
      # 桌面插电平台功耗差异可忽略，稳定性优先。
      "nvidia.NVreg_DynamicPowerManagement=0x00"
      # 以下两个参数在 595.x 中已不作为独立模块参数存在，
      # 但作为 RegistryDwords 键值可能仍然有效，尝试恢复 DP 链路训练优化。
      "nvidia.NVreg_RegistryDwords=EnableDisplayPortLinkTrainingOptimization=1"
    ];
    boot.blacklistedKernelModules = [ "nouveau" ];

    environment.variables = {
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __GL_VRR_ALLOWED = "1";
      NVD_BACKEND = "direct";
      WLR_NO_HARDWARE_CURSORS = "1";
    };

    nixpkgs.config.nvidia.acceptLicense = true;

    hardware = {
      nvidia = {
        open = false;
        nvidiaSettings = true;
        powerManagement.enable = true;
        modesetting.enable = true;
      };
      graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          nvidia-vaapi-driver
          egl-wayland
          libva
        ];
      };
    };

    # niri NVIDIA VRAM 泄漏修复
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

    nix.settings = {
      substituters = [ "https://cuda-maintainers.cachix.org" ];
      trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      ];
    };

    environment.systemPackages = with pkgs; [
      vulkan-tools
      mesa-demos
      libva-utils
    ];
  };
}
