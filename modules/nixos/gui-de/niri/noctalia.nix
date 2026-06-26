{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.mengw.desktop.niri.noctalia;
  niriCfg = config.mengw.desktop.niri;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.niri.noctalia.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Noctalia Shell（Niri 桌面 UI）";
  };

  config = lib.mkIf (cfg.enable && niriCfg.enable && desktopCfg.enable) {
    # Noctalia Shell（桌面 UI）
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
