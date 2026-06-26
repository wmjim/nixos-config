# 通用 Wayland/GNOME 环境变量（Niri 和 GNOME 桌面环境共享）
{ lib, config, ... }:
let
  cfg = config.mengw.desktop.common.env;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.env.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Wayland/GNOME 通用环境变量";
  };

  config = lib.mkIf (cfg.enable && commonCfg.enable && desktopCfg.enable) {
    environment.sessionVariables = {
      # 告诉应用程序当前会话类型是 Wayland，确保它们使用 Wayland 协议而不是 X11
      XDG_SESSION_TYPE = "wayland";

      # 强制 GTK 应用使用 Wayland 后端
      GDK_BACKEND = "wayland";

      # 强制 Qt 应用使用 Wayland 后端
      QT_QPA_PLATFORM = "wayland";
      # Qt 应用的主题引擎，保持与 GTK 应用一致的外观
      QT_QPA_PLATFORMTHEME = "gnome"; # Qt5 应用
      QT_QPA_PLATFORMTHEME_QT6 = "gnome"; # Qt6 应用
      # 禁止 Qt 应用自己画窗口装饰（Mutter/niri 会处理）
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

      # Electron/Chromium 应优先使用 Wayland
      ELECTRON_OZONE_PLATFORM_HINT = "auto";

      # 告诉 Java AWT/Swing 应用在非 reparenting WM 下运行
      _JAVA_AWT_WM_NONREPARENTING = "1";

      # Java 字体渲染优化
      _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=true -Dswing.aatext=true -Dsun.java2d.uiScale=1.5";

      # Clash Verge（代理客户端）的剪贴板权限
      CLASH_VERGE_ALLOW_CLIPBOARD = "1";

      # Rust 程序的回溯信息，方便调试
      RUST_BACKTRACE = "1";
    };
  };
}
