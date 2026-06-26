# 启动日志配置 — 完整详细输出
{ lib, config, ... }:
let
  cfg = config.mengw.desktop.common.boot;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.boot.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用详细启动日志配置";
  };

  config = lib.mkIf (cfg.enable && commonCfg.enable && desktopCfg.enable) {
    boot = {
      # 控制台日志级别: 7 = debug，显示所有消息
      consoleLogLevel = 7;

      # initrd 阶段显示详细信息
      initrd.verbose = true;

      kernelParams = [
        # 始终显示 systemd 服务启动/停止状态
        "systemd.show_status=yes"
        # 不延迟帧缓冲控制台接管
        "fbcon=nodefer"
        # NVIDIA 提供 framebuffer 设备（关机时也能显示）
        "nvidia_drm.fbdev=1"
        # 显式绑定控制台到 VT1，确保关机日志始终有输出目标
        "console=tty1"
      ];
    };
  };
}
