# 启动日志配置 — 安静模式
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  config = lib.mkIf cfg.enable {
    boot = {
      consoleLogLevel = 3;
      initrd.verbose = false;
      kernelParams = [
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
