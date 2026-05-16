# WiFi 和网络管理
{ pkgs, ... }:

{
  # 无线网络：iwd (NetworkManager 后端)
  networking.wireless.iwd.enable = true;

  # WiFi 管理：使用 iwd 后端替代 wpa_supplicant
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";
}
