# 蓝牙支持
{ ... }:

{
  # 蓝牙管理
  hardware.bluetooth.enable = true;
  # 开机自启蓝牙适配器电源
  hardware.bluetooth.powerOnBoot = true;
  # 蓝牙固件
  hardware.enableRedistributableFirmware = true;
  # 阻止 ideapad_laptop 模块初始时屏蔽蓝牙
  boot.extraModprobeConfig = ''
    options ideapad_laptop rfkill_sw_state=1
  '';
}
