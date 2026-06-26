# 编辑器配置
{ lib, config, ... }:
let
  cfg = config.mengw.cli.editors;
in
{
  options.mengw.cli.editors.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用编辑器配置";
  };

  imports = [
    ./helix.nix
    ./neovim.nix
  ];
}
