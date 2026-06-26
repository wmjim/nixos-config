# WiFi 和网络管理
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.hardware.network;
  parentCfg = config.mengw.hardware;
in
{
  options.mengw.hardware.network.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 WiFi 和网络管理（NetworkManager + iwd）";
  };

  config = lib.mkIf (cfg.enable && parentCfg.enable) {
    # 无线网络：iwd (NetworkManager 后端)
    networking.wireless.iwd.enable = true;

    # WiFi 管理：使用 iwd 后端替代 wpa_supplicant
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "iwd";
  };
}
