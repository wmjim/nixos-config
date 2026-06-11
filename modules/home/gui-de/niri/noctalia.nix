{ inputs, pkgs, ... }:
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;

    settings = {
      shell = {
        font_family = "HarmonyOS Sans SC";
      };

      # 指定当 source 是 "builtin" 时使用哪个内置主题
      theme = {
        mode = "dark";
        source = "builtin";
        builtin = "Catppuccin";
      };

      wallpaper = {
        enabled = true;
        default.path = "/home/mengw/files/pictures/wallpaper/wallpaper.png";
      };

      # 显示器亮度 (DP-2 外接显示器使用 DDC/CI)
      brightness = {
        enable_ddcutil = true;
        monitor."DP-2".backend = "ddcutil";
      };

      # 音频
      audio = {
        enable = true;
        enable_overdrive = false; # 是否允许音量滑块超过100%（最高150%）
        enable_sounds = false; # 禁用所有界面音效播放
        sound_volume = 0.5; # 全局音量（0.0 - 1.0）
        volume_change_sound = ""; # 空，内置默认  sounds/volume-change.wav
        notification_sound = ""; # 空，内置默认  sounds/notification.wav
      };
    };
  };
}
