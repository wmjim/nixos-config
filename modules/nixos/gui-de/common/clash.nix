# Clash Verge 配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.desktop.common.clash;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.clash.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Clash Verge 代理客户端";
  };

  config = lib.mkIf (cfg.enable && commonCfg.enable && desktopCfg.enable) {
    programs.clash-verge = {
      enable = true; # 启用 Clash Verge 功能（核心开关）
      autoStart = true; # 系统开机/用户登录后自动启动应用
      serviceMode = true; # 启用系统服务模式（后台守护进程运行，不依赖图形界面）
    };
  };
}
