# PipeWire 音频服务
{ lib, config, ... }:
let
  cfg = config.mengw.hardware.audio;
  parentCfg = config.mengw.hardware;
in
{
  options.mengw.hardware.audio.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 PipeWire 音频服务";
  };

  config = lib.mkIf (cfg.enable && parentCfg.enable) {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
    };
  };
}
