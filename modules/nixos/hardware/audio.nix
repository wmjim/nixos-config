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
  };
}
