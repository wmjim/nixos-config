{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../common/apps.nix
    ../common/wayland-env.nix
  ];

  # 启用 COSMIC 登录管理器
  services.displayManager.cosmic-greeter.enable = true;
  # 自动登录设置
  services.displayManager.autoLogin = {
    enable = true;
    user = "mengw";
  };
  # 启用 COSMIC 桌面环境
  services.desktopManager.cosmic.enable = true;

  #  排除默认情况下由 COSMIC 安装的应用程序
  environment.cosmic.excludePackages = with pkgs; [
    cosmic-term  # COSMIC 自带终端（Ghostty 替代）
    cosmic-icons # COSMIC 自带图标主题
    cosmic-store # COSMIC 自带应用商店
    cosmic-screenshot # COSMIC 自带截图工具
  ];

  # 排除与 COSMIC 自带应用功能重叠的公共应用
  gui-de.commonApps.exclude = with pkgs; [
    kdePackages.dolphin # COSMIC 自带文件管理器 (COSMIC Files)
    kdePackages.ark     # COSMIC Files 已支持压缩/解压
    sublime4            # COSMIC 自带文本编辑器 (COSMIC Edit)
    notepad-next        # COSMIC 自带文本编辑器 (COSMIC Edit)
    mpv                 # COSMIC 自带视频播放器 (COSMIC Video)
    # qview             # 可选：取消注释以排除图片查看器（COSMIC Files 可预览图片）
  ];

  environment.systemPackages = with pkgs; [
    cosmic-wallpapers # COSMIC 壁纸
    cosmic-ext-tweaks # COSMIC 扩展工具，提供额外功能和自定义选项
    cosmic-ext-applet-minimon # COSMIC 小组件扩展，提供CPU/内存/网络/磁盘/GPU使用情况
    cosmic-ext-applet-sysinfo # COSMIC 小组件扩展，提供系统信息显示
    cosmic-ext-calculator # COSMIC 计算器扩展，提供快速计算功能
  ];

  # 启用 System76 Scheduler 提高 COSMIC 性能
  services.system76-scheduler.enable = true;

  # COSMIC 专属环境变量（Wayland 通用变量在 common/wayland-env.nix）
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "COSMIC";
    COSMIC_DATA_CONTROL_ENABLED = 1; # 支持所有窗口全局访问剪贴板
  };
}
