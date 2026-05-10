# 笔记本电源管理
{ ... }:

{
  # 电源配置
  services.power-profiles-daemon.enable = true;
  # 电池功能
  services.upower.enable = true;

  # 电源管理：合盖不休眠
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";               # 普通状态合盖
    HandleLidSwitchDocked = "ignore";         # 外接显示器时合盖
    HandleLidSwitchExternalPower = "ignore";  # 外接电源时合盖
  };
}
