# GUI 应用聚合模块
# 所有 GUI 应用统一由 Home Manager 管理（home.packages）
{ lib, config, ... }:
let
  cfg = config.mengw.gui.apps;
in
{
  options.mengw.gui.apps.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 GUI 应用集合";
  };

  imports = [
    ./ghostty.nix
    ./browsers.nix
    ./communication.nix
    ./media.nix
    ./productivity.nix
    ./development.nix
    ./utilities.nix
    ./pot.nix
  ];
}
