# Niri 窗口管理器 — 系统级配置
{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.mySystem.desktop.niri;
  desktopCfg = config.mySystem.desktop;
in
{
  config = lib.mkIf (cfg.enable && desktopCfg.enable) {
    # 启用 niri
    programs.niri.enable = true;

    # 修补 niri-session 脚本，静默 systemd/dbus 弃用警告
    programs.niri.package = pkgs.niri.overrideAttrs (prev: {
      postPatch = (prev.postPatch or "") + ''
        substituteInPlace resources/niri-session \
          --replace-fail 'systemctl --user import-environment' 'systemctl --user import-environment >/dev/null 2>&1' \
          --replace-fail 'dbus-update-activation-environment --all' 'dbus-update-activation-environment --all >/dev/null 2>&1'
      '';
    });

    # 触控板
    services.libinput.enable = true;

    # Polkit + 密钥环
    security.polkit.enable = true;
    services.gnome.gnome-keyring.enable = true;

    # dconf 数据库
    programs.dconf.enable = true;

    # 桌面门户
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.niri = {
        default = lib.mkForce "gtk;gnome";
      };
    };

    # 注意：XDG_CURRENT_DESKTOP 由 niri-session 在会话启动时自动设置，
    # 不要在此处全局写死，否则 GNOME 等共存桌面会读取到错误的值。

    # xsettingsd（XWayland 字体配置）+ Noctalia Shell

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
        unitConfig = {
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        };
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.xsettingsd}/bin/xsettingsd -c ${xsettingsdConf}";
          Restart = "on-failure";
          RestartSec = 3;
        };
      };

    environment.systemPackages = [
      pkgs.xsettingsd
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    # RDP 远程桌面端口
    networking.firewall.allowedTCPPorts = [ 3389 ];
  };
}
