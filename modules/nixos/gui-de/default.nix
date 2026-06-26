# 桌面环境模块
{ lib, config, ... }:
let
  cfg = config.mengw.desktop;
in
{
  options.mengw.desktop.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用桌面环境模块（通用配置、Niri、GNOME）";
  };

  imports = [
    ./common
    ./niri
    ./gnome
  ];
}
