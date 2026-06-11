# niri 窗口管理器配置（搭配 Noctalia Shell）
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./noctalia.nix
    # ./dms.nix
    ../common/apps.nix
    ../common/wayland-env.nix
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

  # XDG portal（Wayland 屏幕共享、文件选择器等）
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      # KDE port 后端
      kdePackages.xdg-desktop-portal-kde
    ];
    config.niri = {
      default = lib.mkForce "gnome;gtk;kde";
    };
  };

  # niri 专属环境变量（Wayland 通用变量在 common/wayland-env.nix）
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
  };

  # ==========================================
  # xsettingsd: 为 XWayland 应用提供字体配置
  # Java Swing/AWT 在 Wayland 下依赖 XSETTINGS 获取字体名称/大小/抗锯齿等配置，
  # 缺少 xsettingsd 会导致 Java 应用字体大小不一致、快捷键文本异常等问题
  # ==========================================
  environment.systemPackages = [ pkgs.xsettingsd ];

  systemd.user.services.xsettingsd = let
    xsettingsdConf = pkgs.writeText "xsettingsd.conf" ''
      Net/ThemeName "Adwaita"
      Gtk/FontName "HarmonyOS Sans SC, 12"
      Net/IconThemeName "Papirus"
      Xft/Antialias 1
      Xft/Hinting 1
      Xft/HintStyle "hintslight"
      Xft/RGBA "rgb"
    '';
  in {
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
