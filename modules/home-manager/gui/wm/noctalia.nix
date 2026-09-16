# Noctalia Shell 用户级配置
{ lib, config, osConfig, inputs, ... }:
let
  cfg = config.mengw.gui.wm.noctalia;
  wmCfg = config.mengw.gui.wm;
  guiCfg = config.mengw.gui;

  # DDC/CI 亮度依赖 i2c-dev 且需外接显示器支持，仅 desktop 满足
  # （hosts/desktop/default.nix 开了 hardware.i2c.enable，laptop 未开）。
  # laptop 内屏是 eDP，走 sysfs backlight；在 laptop 上 enable_ddcutil 只会让
  # noctalia 反复跑必然失败的 ddcutil detect。
  useDdc = osConfig.networking.hostName == "desktop";
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
          font_family = lib.mkForce "HarmonyOS Sans SC";
        };
        theme = {
          # 默认暗色主题
          mode = "dark";
          source = lib.mkForce "builtin";
          builtin = "Catppuccin";
        };
        wallpaper = {
          enabled = true;
          default.path = "${config.home.homeDirectory}/files/pictures/wallpaper/wallpaper.png";
        };
        brightness = {
          enable_ddcutil = useDdc;
          monitor = lib.mkIf useDdc { "DP-2".backend = "ddcutil"; };
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
