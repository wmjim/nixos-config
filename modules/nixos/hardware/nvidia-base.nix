# NVIDIA 驱动公共基础配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.hardware;
in
{
  # 依赖 mySystem.hardware.enable：NVIDIA 配置体由该开关共同门控，且音频/图形等
  # 配套支持也由它统一启用。单独开启本开关会静默失效，见下方 assertions。
  options.mySystem.hardware.nvidia.enable = lib.mkEnableOption "NVIDIA 驱动（须同时开启 mySystem.hardware.enable）";

  config = lib.mkMerge [
    {
      assertions = [
        {
          assertion = !(cfg.nvidia.enable && !cfg.enable);
          message = ''
            mySystem.hardware.nvidia.enable 已开启，但 mySystem.hardware.enable 未开启。
            NVIDIA 驱动配置仅在二者同时开启时生效，否则 videoDrivers 不会被设为 "nvidia"，
            主机 nvidia.nix 中的 package/prime 等设置也会静默失效（构建通过但开机无驱动）。
          '';
        }
      ];
    }

    (lib.mkIf (cfg.enable && cfg.nvidia.enable) {
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

    environment.systemPackages = with pkgs; [
      vulkan-tools
      mesa-demos
      libva-utils
    ];
    })
  ];
}
