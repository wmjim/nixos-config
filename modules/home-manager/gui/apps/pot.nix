# pot-translation 跨平台划词翻译
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.apps.pot;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;

  pot-icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/pot-app/pot-desktop/master/public/icon.svg";
    hash = "sha256-Fgn8kC4GhIOkzUmGre7OCW5fED5N1AU1KrXbbCh714I=";
  };
  pot-desktop = pkgs.makeDesktopItem {
    name = "pot";
    desktopName = "Pot";
    exec = "pot";
    icon = "${pot-icon}";
    comment = "划词翻译";
    categories = [ "Utility" ];
    terminal = false;
    mimeTypes = [ ];
  };
  tesseract = pkgs.tesseract.override { enableLanguages = [ "eng" "chi_sim" "chi_tra" ]; };
in
{
  options.mengw.gui.apps.pot.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Pot 划词翻译";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    home.packages = [
      pkgs.nur.repos.awa2333.pot-translation
      pot-desktop
      tesseract
      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard
    ];

    home.sessionVariables.TESSDATA_PREFIX = "${tesseract}/share/tessdata";
  };
}
