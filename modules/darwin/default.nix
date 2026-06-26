# macOS (nix-darwin) 模块
{ lib, config, ... }:
let
  cfg = config.mengw.darwin;
in
{
  options.mengw.darwin.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 macOS (nix-darwin) 模块";
  };

  imports = [
    ./gui.nix
  ];
}
