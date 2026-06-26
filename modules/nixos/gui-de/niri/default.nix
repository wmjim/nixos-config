# niri 窗口管理器
{ lib, config, ... }:
let
  cfg = config.mengw.desktop.niri;
in
{
  options.mengw.desktop.niri.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Niri 窗口管理器";
  };

  imports = [
    ./niri.nix
  ];
}
