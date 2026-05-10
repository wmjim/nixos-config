# niri 窗口管理器 — 用户级配置文件部署
{ config, pkgs, lib, ... }:

{
  # 主配置文件部署到 ~/.config/niri/
  xdg.configFile."niri/config.kdl" = {
    source = ./config/config.kdl;
    force = true;
  };
  xdg.configFile."niri/animations.kdl" = {
    source = ./config/animations.kdl;
    force = true;
  };
  xdg.configFile."niri/layout.kdl" = {
    source = ./config/layout.kdl;
    force = true;
  };
  xdg.configFile."niri/blur.kdl" = {
    source = ./config/blur.kdl;
    force = true;
  };
  xdg.configFile."niri/shorin-windowrules.kdl" = {
    source = ./config/shorin-windowrules.kdl;
    force = true;
  };

  xdg.configFile."niri/dms/alttab.kdl" = {
    source = ./config/dms/alttab.kdl;
    force = true;
  };
  xdg.configFile."niri/dms/binds.kdl" = {
    source = ./config/dms/binds.kdl;
    force = true;
  };
  xdg.configFile."niri/dms/cursor.kdl" = {
    source = ./config/dms/cursor.kdl;
    force = true;
  };
  xdg.configFile."niri/dms/layout.kdl" = {
    source = ./config/dms/layout.kdl;
    force = true;
  };
  xdg.configFile."niri/dms/outputs.kdl" = {
    source = ./config/dms/outputs.kdl;
    force = true;
  };
  xdg.configFile."niri/dms/supertab.kdl" = {
    source = ./config/dms/supertab.kdl;
    force = true;
  };

  # 脚本部署到 ~/.config/niri/scripts/（保留可执行权限）
  xdg.configFile."niri/scripts/screenshot-sound.sh" = {
    source = ./config/scripts/screenshot-sound.sh;
    executable = true;
    force = true;
  };

  xdg.configFile."niri/scripts/niri-binds.sh" = {
    source = ./config/scripts/niri-binds.sh;
    executable = true;
    force = true;
  };

  xdg.configFile."niri/scripts/niri-pick.sh" = {
    source = ./config/scripts/niri-pick.sh;
    executable = true;
    force = true;
  };
}
