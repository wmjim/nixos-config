# Wayland/GNOME 通用环境变量
{ lib, config, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "gnome";
      QT_QPA_PLATFORMTHEME_QT6 = "gnome";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=true -Dswing.aatext=true -Dsun.java2d.uiScale=1.5";
      CLASH_VERGE_ALLOW_CLIPBOARD = "1";
      RUST_BACKTRACE = "1";
    };
  };
}
