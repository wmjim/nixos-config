# 启动日志配置 — 详细输出
{ lib, config, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  config = lib.mkIf cfg.enable {
    boot = {
      consoleLogLevel = 7;
      initrd.verbose = true;
      kernelParams = [
        "systemd.show_status=yes"
        "fbcon=nodefer"
        "nvidia_drm.fbdev=1"
        "console=tty1"
      ];
    };
  };
}
