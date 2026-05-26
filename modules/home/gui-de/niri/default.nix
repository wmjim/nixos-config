# niri 窗口管理器 — 用户级配置文件部署
{ config, pkgs, lib, ... }:

{

  imports = [
    ./noctalia.nix
  ];

  # 主配置文件
  xdg.configFile."niri/config.kdl" = {
    source = ./config/config.kdl;
    force = true;
  };

  # 核心配置：环境变量、输入设备、自启程序、显示器
  xdg.configFile."niri/core/env.kdl" = {
    source = ./config/core/env.kdl;
    force = true;
  };
  xdg.configFile."niri/core/input.kdl" = {
    source = ./config/core/input.kdl;
    force = true;
  };
  xdg.configFile."niri/core/startup.kdl" = {
    source = ./config/core/startup.kdl;
    force = true;
  };
  xdg.configFile."niri/core/outputs.kdl" = {
    source = ./config/core/outputs.kdl;
    force = true;
  };

  # 视觉效果：动画、模糊、磨砂玻璃、布局、光标、概览
  xdg.configFile."niri/visual/animations.kdl" = {
    source = ./config/visual/animations.kdl;
    force = true;
  };
  xdg.configFile."niri/visual/blur.kdl" = {
    source = ./config/visual/blur.kdl;
    force = true;
  };
  xdg.configFile."niri/visual/frosted-glass.kdl" = {
    source = ./config/visual/frosted-glass.kdl;
    force = true;
  };
  xdg.configFile."niri/visual/layout.kdl" = {
    source = ./config/visual/layout.kdl;
    force = true;
  };
  xdg.configFile."niri/visual/cursor.kdl" = {
    source = ./config/visual/cursor.kdl;
    force = true;
  };
  xdg.configFile."niri/visual/overview.kdl" = {
    source = ./config/visual/overview.kdl;
    force = true;
  };

  # 快捷键：系统、导航、应用
  xdg.configFile."niri/binds/system.kdl" = {
    source = ./config/binds/system.kdl;
    force = true;
  };
  xdg.configFile."niri/binds/navigation.kdl" = {
    source = ./config/binds/navigation.kdl;
    force = true;
  };
  xdg.configFile."niri/binds/apps.kdl" = {
    source = ./config/binds/apps.kdl;
    force = true;
  };

  # 窗口规则
  xdg.configFile."niri/windowrules.kdl" = {
    source = ./config/windowrules.kdl;
    force = true;
  };

  xdg.configFile."niri/scripts/niri-binds.sh" = {
    source = ./config/scripts/niri-binds.sh;
    executable = true;
    force = true;
  };
}
