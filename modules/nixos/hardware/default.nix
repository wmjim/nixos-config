# 硬件模块聚合
# 各主机按需导入此目录下的子模块
{ lib, config, ... }:
let
  cfg = config.mengw.hardware;
in
{
  options.mengw.hardware.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用硬件支持模块（蓝牙、音频、网络）";
  };

  imports = [
    ./bluetooth.nix
    ./audio.nix
    ./network.nix
  ];
}
