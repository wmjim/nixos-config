# DMS (Dank Material Shell) 配置
{ config, pkgs, inputs, ... }:

{
  imports = [ inputs.dms-plugin-registry.modules.default ];

  # 登录管理器：greetd + tuigreet
  services.displayManager.dms-greeter = {
    enable = true;
    compositor = {
      name = "niri";
      customConfig = "";
    };
    configHome = "/home/mengw";

    configFiles = [
      "/home/mengw/.config/DankMaterialShell/settings.json"
    ];
    logs = {
      save = true;
      path = "/tmp/dms-greeter.log";
    };
    quickshell.package = pkgs.quickshell;
  };

  programs.dms-shell = {
    enable = true;                    # 启动 dms

    systemd = {
      enable = true;                  # 自动启动
      restartIfChanged = true;        # 当 dms-shell 发生变化时重启 dms.service
    };

    # 核心功能
    enableSystemMonitoring = true;    # 系统监控小部件（dgop） 
    enableVPN = true;                 # VPN 管理小部件
    enableDynamicTheming = true;      # 基于壁纸的主题（matugen）
    enableAudioWavelength = true;     # 音频可视化器（cava）
    enableCalendarEvents = true;      # 日历集成（khal）
    enableClipboardPaste = true;      # 从剪贴板历史中粘贴（wtype）

    plugins = {
      dankBatteryAlerts.enable = true;
      dockerManager.enable = true;
    };
  };
}
