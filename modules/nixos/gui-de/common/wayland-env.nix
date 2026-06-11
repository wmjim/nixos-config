# Wayland 通用环境变量（所有桌面环境共享）
{ ... }:

{
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";

    # Qt 应用强制使用 Wayland
    QT_QPA_PLATFORM = "wayland";
    # QGnomePlatform 让 Qt 应用自动跟随 GTK/Adwaita 主题
    QT_QPA_PLATFORMTHEME = "gnome";
    QT_QPA_PLATFORMTHEME_QT6 = "gnome";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Electron/Chromium 应用使用 Wayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";

    # Firefox 使用 Wayland
    MOZ_ENABLE_WAYLAND = "1";

    # Java AWT/Swing 应用在 Wayland（非 reparenting WM）下需要此变量，否则白屏
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # Java 字体渲染优化（Swing/AWT 应用在 Wayland 下字体不一致的修复）
    # - awt.useSystemAAFontSettings=lcd LCD 子像素渲染，比灰度抗锯齿(on)更锐利清晰
    # - swing.aatext=true              启用 Swing 文本抗锯齿
    # - sun.java2d.uiScale=1.5         显式设置缩放，避免 XWayland DPI 误判
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=lcd -Dswing.aatext=true -Dsun.java2d.uiScale=1.5";

  # 其他
  CLASH_VERGE_ALLOW_CLIPBOARD = "1";
  RUST_BACKTRACE = "1";
  };
}
