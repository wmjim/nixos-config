# PipeWire 音频服务
{ ... }:

{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };
}
