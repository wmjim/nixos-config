# GUI 应用配置
{ lib, config, ... }:
let
  cfg = config.mengw.gui.apps;
in
{
  options.mengw.gui.apps.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 GUI 应用配置";
  };

  imports = [
    ./ghostty
  ];
}
