# PipeWire 音频服务
{ lib, config, ... }:
let
  cfg = config.mySystem.hardware;
in
{
  options.mySystem.hardware.audio.enable = lib.mkEnableOption "PipeWire 音频服务";

  config = lib.mkIf (cfg.enable && cfg.audio.enable) {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };

    # 禁用声卡电源休眠:ALC1220 静音 10s 后会睡到 D3,唤醒时 DAC 渐入导致开头声音偏小
    boot.extraModprobeConfig = ''
      options snd-hda-intel power_save=0
    '';
  };
}
