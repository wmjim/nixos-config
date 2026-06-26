# GDM 登录管理器 + Thyx 主题
# 统一的图形登录界面，可在 GNOME / Niri 等桌面环境之间切换
{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.mengw.desktop.common.gdm;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.gdm.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 GDM 登录管理器";
  };

  config = lib.mkIf (cfg.enable && commonCfg.enable && desktopCfg.enable) {
    # 使用 GDM 作为显示管理器（登录界面）
    # services.displayManager.gdm.enable = true;
    services.xserver.displayManager.gdm.enable = true;
  };
}
