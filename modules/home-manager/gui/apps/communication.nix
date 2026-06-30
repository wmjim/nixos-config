# 通讯工具
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.apps.communication;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;

  wechat-scaled = pkgs.symlinkJoin {
    name = "wechat-scaled";
    paths = [ pkgs.wechat ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/wechat \
        --unset WAYLAND_DISPLAY \
        --set QT_QPA_PLATFORM "wayland;xcb" \
        --set QT_SCALE_FACTOR 1.25 \
        --set GTK_IM_MODULE "fcitx" \
        --set QT_IM_MODULE "fcitx" \
        --set XMODIFIERS "@im=fcitx"
    '';
  };
in
{
  options.mengw.gui.apps.communication.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用通讯工具";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    home.packages = with pkgs; [
      discord
      telegram-desktop
      wechat-scaled
      qq
    ];
  };
}
