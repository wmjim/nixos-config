# Wayland/GNOME 通用环境变量
{ lib, config, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  config = lib.mkIf cfg.enable {
    environment.sessionVariables = {
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_SESSION_TYPE = "wayland";
      GDK_BACKEND = "wayland";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "gnome";
      # 注释：交由 Stylix 统一管理 Qt6 平台主题
      # QT_QPA_PLATFORMTHEME_QT6 = "gnome";
      # 注释：恢复 Qt 客户端自绘标题栏
      # 原为 GNOME SSD 而设，Niri 的 SSD 极简会导致标题栏消失
      # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=true -Dswing.aatext=true -Dsun.java2d.uiScale=1.5";
      RUST_BACKTRACE = "1";
    };
  };
}
