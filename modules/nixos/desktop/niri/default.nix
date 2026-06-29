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

    # RDP 远程桌面端口
    networking.firewall.allowedTCPPorts = [ 3389 ];
  };
}
