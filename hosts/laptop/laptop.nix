{ config, pkgs, lib, ... }:

{
  # 电池状态监控
  services.upower.enable = true;
  # Intel CPU 主动温控，防止 BIOS 因温度波动暴力拉风扇
  services.thermald.enable = true;
  services.throttled.enable = true;

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
      governor = "powersave";
      turbo = "auto";
    };
  };
  # TLP 进阶电源管理（部分机型可影响风扇策略）
  services.tlp.enable = true;

  # auto-cpufreq GUI 通过 pkexec 提权，Wayland 下无 polkit agent 会失败
  # 允许 wheel 组成员免密码执行 auto-cpufreq
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.auto-cpufreq.pkexec" && subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';  
  # 温度监控工具
  environment.systemPackages = with pkgs; [ lm_sensors ];
}