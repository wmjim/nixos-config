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
    # 实验(2026-08-08)：移除 video= 强制模式，让原生 150Hz 直接暴露。
    # 之前 video=DP-2:3840x2160@150 会创建 user-defined 模式，显示器唤醒时
    # 被 NVIDIA 拒绝报 "User-defined mode not supported" → 黑屏。
    # EDID 固件的 DisplayID 块已原生声明 3840x2160@150Hz(1329MHz)，144/120Hz
    # 均以原生 driver 模式暴露，仅 150Hz 因 video= 变为 userdef。
    # 移除后若 150Hz 以原生模式出现且唤醒正常，则确认问题在 user-defined 模式本身。
    # 不使用 e 标志强制输出：e 会阻止连接器热插拔事件，导致物理断电再上电后
    # DP 链路无法重新训练 → 黑屏。
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
