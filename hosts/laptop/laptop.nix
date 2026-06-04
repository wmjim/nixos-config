{ config, pkgs, lib, ... }:

{
  # 电池状态监控
  services.upower.enable = true;
  # 温控守护进程，CPU 温度过高时主动降温
  # 关闭：thermald 的功耗上限调整反而可能触发 BIOS 暴力拉风扇
  services.thermald.enable = false;

  # 电源管理：合盖不休眠
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore"; # 普通状态合盖
    HandleLidSwitchDocked = "ignore"; # 外接显示器时合盖
    HandleLidSwitchExternalPower = "ignore"; # 外接电源时合盖
  };

  # 禁用默认的 power-profiles-daemon，避免与 auto-cpufreq/tlp 冲突
  services.power-profiles-daemon.enable = false;

  # 电源管理工具
  # TLP 进阶电源管理（部分机型可影响风扇策略）
  services.tlp.enable = true;

  services.tlp.settings = {
    # 插电：性能均衡，风扇不会因 turbo 频繁启停
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    CPU_BOOST_ON_AC = "1";

    # 电池：以安静省电为主
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
    CPU_BOOST_ON_BAT = "0";

    # 插电时稍微激进一点的温控策略（温度低一点再起风扇）
    PLATFORM_PROFILE_ON_AC = "balanced";
    PLATFORM_PROFILE_ON_BAT = "low-power";

    # 防止 TLP 自动挂起蓝牙 USB 设备导致蓝牙被关闭
    USB_EXCLUDE_BTUSB = "1";
  };


  # 温度监控工具：sensors 查看 CPU 温度
  environment.systemPackages = with pkgs; [ lm_sensors ];
}
