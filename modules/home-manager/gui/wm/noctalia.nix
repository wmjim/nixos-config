# Noctalia Shell 用户级配置
{ lib, config, inputs, ... }:
let
  cfg = config.mengw.gui.wm.noctalia;
  wmCfg = config.mengw.gui.wm;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.wm.noctalia.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Noctalia Shell 用户级配置";
  };

  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf (cfg.enable && wmCfg.enable && guiCfg.enable) {
    programs.noctalia = {
      enable = true;
      settings = {
        shell = {
          font_family = "HarmonyOS Sans SC";
        };
        theme = {
          mode = "dark";
          source = "builtin";
          builtin = "Catppuccin";
        };
        wallpaper = {
          enabled = true;
          default.path = "/home/mengw/files/pictures/wallpaper/wallpaper.png";
        };
        brightness = {
          enable_ddcutil = true;
          monitor."DP-2".backend = "ddcutil";
        };
        audio = {
          enable = true;
          enable_overdrive = true;
          enable_sounds = false;
          sound_volume = 0.6;
          volume_change_sound = "";
          notification_sound = "";
        };
      };
    };
  };
}
