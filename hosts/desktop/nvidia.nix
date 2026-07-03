# NVIDIA 驱动 — RTX 3060Ti
{ config, pkgs, lib, ... }:

let
  edid-firmware = pkgs.stdenvNoCC.mkDerivation {
    name = "dp2-edid-firmware";
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out/lib/firmware/edid
      cp ${./dp2-edid.bin} $out/lib/firmware/edid/dp2-edid.bin
    '';
  };
in
{
  imports = [ ../../modules/nixos/hardware/nvidia-base.nix ];

  # 提取显示器 EDID 并作为固件加载，彻底绕过 I2C 读取失败的根因
  # 当显示器休眠唤醒后，NVIDIA 驱动不再需要通过 DP I2C 读取 EDID，
  # 直接使用此固件文件提供正确的分辨率/刷新率模式
  hardware.firmware = [ edid-firmware ];
  boot.kernelParams = [
    "drm.edid_firmware=DP-2:edid/dp2-edid.bin"
    # 强制 DP-2 输出模式 — 唤醒时无需等待 I2C EDID 读取即可恢复显示
    # e 标志表示即使未检测到显示器也强制启用输出
    "video=DP-2:3840x2160@150e"
    # 禁止内核 VT 控制台超时熄屏，防止触发不必要的 DPMS 状态切换
    "consoleblank=0"
  ];

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
