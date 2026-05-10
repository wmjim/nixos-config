# WiFi 和网络管理
{ pkgs, ... }:

{
  # 无线网络：iwd
  systemd.services.iwd = {
    enable = true;
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.iwd}/libexec/iwd";
      Restart = "on-failure";
    };
  };

  # WiFi 管理
  networking.networkmanager.enable = true;
}
