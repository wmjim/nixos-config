# niri 窗口管理器配置（搭配 Noctalia Shell）
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    ./noctalia.nix
    ../common/apps.nix
  ];

  # 启用 niri
  programs.niri.enable = true;

  # 修补 niri-session 脚本，静默 systemd/dbus 弃用警告
  # 上游 issue: https://github.com/niri-wm/niri/issues/254
  programs.niri.package = pkgs.niri.overrideAttrs (prev: {
    postPatch = (prev.postPatch or "") + ''
      substituteInPlace resources/niri-session \
        --replace-fail 'systemctl --user import-environment' 'systemctl --user import-environment >/dev/null 2>&1' \
        --replace-fail 'dbus-update-activation-environment --all' 'dbus-update-activation-environment --all >/dev/null 2>&1'
    '';
  });

  # 触控板
  services.libinput.enable = true;

  # Polkit + 密钥环（图形会话需要）
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # dconf 数据库（GNOME/GTK 应用读取配置必需）
  programs.dconf.enable = true;

  # 桌面门户服务配置
  # 提供文件选择、屏幕共享、截图等功能底层支持
  xdg.portal = {
    enable = true;
    # 安装并启用额外的 Portal 后端
    extraPortals = with pkgs; [
      # GTK 后端，作为轻量级兜底提供文件选择器
      xdg-desktop-portal-gtk
      # GNOME 后端，提供符合 GNOME 风格的 UI 弹窗
      xdg-desktop-portal-gnome
    ];
    # 当应用发起请求时，排在最前面的 Portal 会优先尝试响应
    # 先轻量级 gtk，后全功能 gnome
    config.niri = {
      default = lib.mkForce "gtk;gnome";
    };
  };

  # niri 环境变量
  environment.sessionVariables = {
    # 告诉应用程序当前桌面环境是 niri，某些应用可能会根据这个变量调整行为或外观
    XDG_CURRENT_DESKTOP = "niri";
    # 告诉应用程序当前会话类型是 Wayland，确保它们使用 Wayland 协议而不是 X11
    XDG_SESSION_TYPE = "wayland";
    # 强制 GTK 应用使用 Wayland 后端，避免在 Wayland 会话中回退到 X11 导致性能和兼容性问题
    GDK_BACKEND = "wayland";

    # 强制 Qt 应用使用 Wayland 后端，避免在 Wayland 会话中回退到 X11 导致性能和兼容性问题
    QT_QPA_PLATFORM = "wayland";
    # Qt 应用的主题引擎，保持与 GTK 应用一致的外观
    QT_QPA_PLATFORMTHEME = "gnome"; # Qt5 应用
    QT_QPA_PLATFORMTHEME_QT6 = "gnome"; # Qt6 应用
    # 禁止 Qt 应用自己画窗口装饰
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";

    # Electron/Chromium 应优先使用 Wayland
    ELECTRON_OZONE_PLATFORM_HINT = "auto";

    # 告诉 Java AWT/Swing 应用在非 reparenting WM 下运行
    # niri 不提供 X11 风格的 reparenting。没有这个变量，Java GUI 应用会白屏
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # Java 虚拟机的启动参数
    # Java 字体渲染优化（Swing/AWT 应用在 Wayland 下字体不一致的修复）
    # - awt.useSystemAAFontSettings=true 灰度抗锯齿
    # - swing.aatext=true              启用 Swing 文本抗锯齿
    # - sun.java2d.uiScale=1.5         显式设置缩放，避免 XWayland DPI 误判
    _JAVA_OPTIONS = "-Dawt.useSystemAAFontSettings=true -Dswing.aatext=true -Dsun.java2d.uiScale=1.5";

    # Clash Verge（代理客户端）的剪贴板权限
    CLASH_VERGE_ALLOW_CLIPBOARD = "1";
    # Rust 程序的回溯信息，方便调试 Rust 应用崩溃时的错误信息
    RUST_BACKTRACE = "1";
  };

  # ==========================================
  # xsettingsd: 为 XWayland 应用提供字体配置
  # Java Swing/AWT 在 Wayland 下依赖 XSETTINGS 获取字体名称/大小/抗锯齿等配置，
  # 缺少 xsettingsd 会导致 Java 应用字体大小不一致、快捷键文本异常等问题
  # ==========================================
  environment.systemPackages = [ pkgs.xsettingsd ];

  systemd.user.services.xsettingsd =
    let
      xsettingsdConf = pkgs.writeText "xsettingsd.conf" ''
        Net/ThemeName "Adwaita"
        Gtk/FontName "HarmonyOS Sans SC, 12"
        Net/IconThemeName "Papirus"
        Xft/Antialias 1
        Xft/Hinting 1
        Xft/HintStyle "hintslight"
        Xft/RGBA "rgb"
        Xft/DPI 147456
      '';
    in
    {
      description = "XSettings daemon (font config for XWayland apps like Java Swing)";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.xsettingsd}/bin/xsettingsd -c ${xsettingsdConf}";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };

  # RDP 远程桌面端口
  networking.firewall.allowedTCPPorts = [ 3389 ];
}
