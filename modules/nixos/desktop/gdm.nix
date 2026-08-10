# GDM 登录管理器
{ lib, config, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  config = lib.mkIf cfg.enable {
    # 启用 GDM 作为显示管理器
    services.displayManager.gdm.enable = true;
  };
}
