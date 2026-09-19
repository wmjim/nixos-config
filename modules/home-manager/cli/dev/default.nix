# 开发工具配置
{ lib, config, ... }:
let
  cfg = config.mengw.cli.dev;
in
{
  options.mengw.cli.dev.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用开发工具（所有语言）";
  };

  imports = [
    ./node.nix
    ./python.nix
    ./rust.nix
    ./go.nix
    ./cpp.nix
    ./others.nix
  ];
}
