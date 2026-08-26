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
      # QT_QPA_PLATFORMTHEME_QT6 = "gnome";
      # 注释：恢复 Qt 客户端自绘标题栏
      # 原为 GNOME SSD 而设，Niri 的 SSD 极简会导致标题栏消失
      # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=true -Dswing.aatext=true -Dsun.java2d.uiScale=1.5";
      RUST_BACKTRACE = "1";
      # XWayland 应用（Steam 及其游戏）光标主题/大小：
      # Niri 自身从 config.kdl 读取光标配置，但 XWayland 走 XCURSOR_* 环境变量；
      # 缺失时 libXcursor 回退默认光标（Steam 里出现小且方向异常的箭头）。
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "48";
    };
  };
}
