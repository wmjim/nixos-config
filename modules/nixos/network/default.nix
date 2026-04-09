# 网络配置模块
{ config, pkgs, ... }:

{
  imports = [
    ./clash.nix
  ];

  # Tailscale
  services.tailscale.enable = true;
}
