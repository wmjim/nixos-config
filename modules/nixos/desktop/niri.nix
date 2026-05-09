# niri 窗口管理器配置（搭配 Noctalia Shell）
{ config, pkgs, lib, inputs, ... }:

{
  imports = [ inputs.dms-plugin-registry.modules.default ];

  # niri 合成器（来自 nixpkgs）
  programs.niri.enable = true;

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
    # 将日志保存到文件
    logs = {
      save = true;
      path = "/tmp/dms-greeter.log";
    };
    quickshell.package = pkgs.quickshell;
  };

  # 触控板
  services.libinput.enable = true;

  # Polkit + 密钥环（图形会话需要）
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # XDG portal（Wayland 屏幕共享、文件选择器等）
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.niri = {
      default = [ "gnome" "gtk" ];
    };
  };

  programs.dms-shell = {
    enable = true;               # 启动 DMS

    systemd = {
      enable = true;             # 自动启动的Systemd服务
      restartIfChanged = true;   # 当 dms-shell 发生变化时自动重启 dms.service
    };

    # 核心功能
    enableSystemMonitoring = true;     # 系统监控小部件 (dgop)
    enableVPN = true;                  # VPN管理小部件
    enableDynamicTheming = true;       # 基于壁纸的主题（matugen）
    enableAudioWavelength = true;      # 音频可视化器（cava）
    enableCalendarEvents = true;       # 日历集成 (khal)
    enableClipboardPaste = true;       # 从剪贴板历史中粘贴（wtype）

    plugins = {
        dankBatteryAlerts.enable = true;
        dockerManager.enable = true;
    };
  };

  # Wayland / niri 环境变量
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    CLASH_VERGE_ALLOW_CLIPBOARD = "1";
    RUST_BACKTRACE = "1";
    GTK_THEME = "WhiteSur-Dark";
    GTK_ICON_THEME = "WhiteSur";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  # 系统级图形/音频/桌面工具
  environment.systemPackages = with pkgs; [
    # niri 周边
    xwayland-satellite           # 运行 X11 应用
    swaylock-effects             # 锁屏
    swayidle                     # 空闲触发
    wl-clipboard                 # 剪贴板
    cliphist                     # 剪贴板历史
    grim slurp                   # 截图
    wf-recorder                  # 屏幕录制
    brightnessctl                # 亮度控制
    playerctl                    # 媒体控制
    pamixer                      # 音量控制
    networkmanagerapplet         # 网络托盘
    pavucontrol                  # 音量 GUI
    libnotify                    # 通知相关库
    polkit_gnome                 # 询问管理员权限
    fuzzel                       # 应用启动器
    kdePackages.dolphin          # 文件管理器
    bluez                        # 蓝牙主体
    blueman                      # 蓝牙图形界面
    # awww                         # 壁纸切换功能
    # waypaper                     # 壁纸图形界面

    # 常用应用
    microsoft-edge
    zed-editor
    vscode
    obsidian
    thunderbird
  ];

  # RDP 远程桌面端口（保留）
  networking.firewall.allowedTCPPorts = [ 3389 ];
}
