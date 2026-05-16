{ config, pkgs, lib, ... }:

{
  # 电池状态监控
  services.upower.enable = true;
  # Intel CPU 主动温控，防止 BIOS 因温度波动暴力拉风扇
  services.thermald.enable = true;

  # 电源管理：合盖不休眠
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";               # 普通状态合盖
    HandleLidSwitchDocked = "ignore";         # 外接显示器时合盖
    HandleLidSwitchExternalPower = "ignore";  # 外接电源时合盖
  };

  # 禁用默认的 power-profiles-daemon，避免与 auto-cpufreq/tlp 冲突
  services.power-profiles-daemon.enable = false;

  # 电源管理：电池模式降频降噪，插电恢复性能
  services.auto-cpufreq.enable = true;
  services.auto-cpufreq.settings = {
    battery = {
      governor = "powersave";
      turbo = "never";
    };
    charger = {
      governor = "performance";
      turbo = "auto";
    };
  };
  # TLP 进阶电源管理（部分机型可影响风扇策略）
  services.tlp.enable = true;  
  # 温度监控工具
  environment.systemPackages = with pkgs; [ lm_sensors ];
}