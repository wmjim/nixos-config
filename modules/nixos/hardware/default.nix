# 硬件模块聚合
# mySystem.hardware.enable = true 时自动启用所有子模块（可用 mkForce 禁用单个）
{ lib, config, ... }:
let
  cfg = config.mySystem.hardware;
in
{
  imports = [
    ./bluetooth.nix
    ./audio.nix
    ./network.nix
    ./nvidia-base.nix
  ];

  config = lib.mkIf cfg.enable {
    mySystem.hardware.audio.enable = lib.mkDefault true;
    mySystem.hardware.bluetooth.enable = lib.mkDefault true;
    mySystem.hardware.network.enable = lib.mkDefault true;
    # nvidia 需要主机显式开启（server/WSL 不需要）
  };
}
