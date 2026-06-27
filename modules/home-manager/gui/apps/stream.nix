# 游戏
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mengw.gui.apps.stream;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.stream.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "管理你的游戏";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    programs.steam = {
      enable = true;
    };

    home.packages = with pkgs; [
      stream
      stream-unwrapped
    ];
  };
}
