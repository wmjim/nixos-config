# 蓝牙支持
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.hardware;
in
{
  options.mySystem.hardware.bluetooth.enable = lib.mkEnableOption "蓝牙支持";

  config = lib.mkIf (cfg.enable && cfg.bluetooth.enable) {
    hardware.bluetooth.enable = true;
    hardware.bluetooth.powerOnBoot = true;
    hardware.enableRedistributableFirmware = true;

    boot.extraModprobeConfig = ''
      options ideapad_laptop rfkill_sw_state=1
    '';

    systemd.services.unblock-bluetooth = {
      description = "Unblock Bluetooth rfkill after systemd-rfkill restore";
      after = [ "systemd-rfkill.service" ];
      wantedBy = [ "bluetooth.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.util-linux}/bin/rfkill unblock bluetooth";
        RemainAfterExit = true;
      };
    };
  };
}
