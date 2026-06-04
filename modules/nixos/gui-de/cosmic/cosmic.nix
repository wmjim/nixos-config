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
    # cosmic-edit
  ];

  # 启用 System76 Scheduler 提高 COSMIC 性能
  services.system76-scheduler.enable = true;

  # COSMIC 专属环境变量（Wayland 通用变量在 common/wayland-env.nix）
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "COSMIC";
    COSMIC_DATA_CONTROL_ENABLED = 1; # 支持所有窗口全局访问剪贴板
  };
}