# Wayland 通用环境变量（所有桌面环境共享）
{ ... }:

{
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";

    # Qt 应用强制使用 Wayland
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Electron/Chromium 应用使用 Wayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
    NIXOS_OZONE_WL = "1";

    # Firefox 使用 Wayland
    MOZ_ENABLE_WAYLAND = "1";

    # 其他
    CLASH_VERGE_ALLOW_CLIPBOARD = "1";
    RUST_BACKTRACE = "1";
  };
}
