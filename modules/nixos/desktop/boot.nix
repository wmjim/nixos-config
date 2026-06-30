# 启动日志配置 — 详细输出
{ lib, config, pkgs, ... }:
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

    # TTY 控制台字体 — Terminus 32px 粗体，适配高分屏
    # console.packages 确保字体在 initrd 早期阶段可用
    console = {
      font = "ter-i32b";
      packages = [ pkgs.terminus_font ];
      earlySetup = true;
    };
  };
}
