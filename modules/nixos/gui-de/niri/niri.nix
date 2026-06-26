# niri 窗口管理器配置（搭配 Noctalia Shell）
{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.mengw.desktop.niri.wm;
  niriCfg = config.mengw.desktop.niri;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.niri.wm.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Niri 窗口管理器核心配置";
  };

  imports = [
    ./noctalia.nix
    ../common/apps.nix
  ];

  config = lib.mkIf (cfg.enable && niriCfg.enable && desktopCfg.enable) {
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

    # niri 专用环境变量（通用变量在 common/env.nix）
    environment.sessionVariables = {
      # 告诉应用程序当前桌面环境是 niri
      XDG_CURRENT_DESKTOP = "niri";
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
  };
}
