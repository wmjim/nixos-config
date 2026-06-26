# WiFi 和网络管理
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.hardware;
in
{
  options.mySystem.hardware.network.enable = lib.mkEnableOption "WiFi 和网络管理（NetworkManager + iwd）";

  config = lib.mkIf (cfg.enable && cfg.network.enable) {
    networking.wireless.iwd.enable = true;
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "iwd";
  };
}
