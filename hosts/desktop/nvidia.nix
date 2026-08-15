# NVIDIA 驱动 — RTX 3060Ti
{ config, ... }:

{
  imports = [ ../../modules/nixos/hardware/nvidia-base.nix ];

  # 实验(2026-08-10)：移除自定义 EDID 固件覆盖（drm.edid_firmware），
  # 排查显示器物理断电再上电后黑屏问题。
  # 机制：固件 EDID 会在显示器断电、真实 EDID 读取失败时顶上，连接器始终
  # 显示 connected，驱动从不登记断开 → 上电后不自动重训练 DP 链路 → 黑屏。
  # 移除后应恢复正常的断开/重连流程，实现自动恢复（无需切 TTY/重启）。
  # 120Hz 是原生标准模式不受影响；150Hz 依赖固件 EDID 的 DisplayID 块会失去。
  # 若显示器唤醒时 I2C EDID 读取失败问题回归，可还原此配置（dp2-edid.bin 仍在仓库）。
  boot.kernelParams = [
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
