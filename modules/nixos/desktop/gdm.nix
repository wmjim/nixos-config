# GDM 登录管理器
{ lib, config, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  config = lib.mkIf cfg.enable {
    services.displayManager.gdm.enable = true;
  };
}
