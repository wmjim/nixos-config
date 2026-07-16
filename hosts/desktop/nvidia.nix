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
    # 声明 DP-2 首选输出模式。不使用 e 标志强制输出：
    # e 标志会阻止正常的连接器断开/重连热插拔事件，导致显示器物理
    # 断电再上电后 DP 链路无法重新训练 → 黑屏。EDID 固件已解决 I2C
    # 读取失败问题，无需再通过 e 标志屏蔽热插拔。
    "video=DP-2:3840x2160@150"
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
