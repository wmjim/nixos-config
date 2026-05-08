{ config, pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
        libsForQt5.fcitx5-qt
        fcitx5-material-color
        (fcitx5-rime.override {
          rimeDataPkgs = [ pkgs.rime-ice ];
        })
      ];
    };
  };
}