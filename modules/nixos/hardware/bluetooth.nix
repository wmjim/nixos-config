# 蓝牙支持
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.hardware.bluetooth;
  parentCfg = config.mengw.hardware;
in
{
  options.mengw.hardware.bluetooth.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用蓝牙支持";
  };

  config = lib.mkIf (cfg.enable && parentCfg.enable) {
    # 启用对蓝牙设备的支持
    hardware.bluetooth.enable = true;
    # 开机自启蓝牙适配器电源
    hardware.bluetooth.powerOnBoot = true;
    # 蓝牙固件
    hardware.enableRedistributableFirmware = true;
    # 阻止 ideapad_laptop 模块初始时屏蔽蓝牙
    boot.extraModprobeConfig = ''
      options ideapad_laptop rfkill_sw_state=1
    '';

    # systemd-rfkill 会在启动时恢复上次关机时保存的 rfkill 状态，
    # 覆盖内核参数。这个服务在 systemd-rfkill 之后强制解锁蓝牙。
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
