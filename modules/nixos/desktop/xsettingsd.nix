# xsettingsd（XWayland 字体/光标/主题配置）+ Noctalia Shell
# niri 和 GNOME 共用：为 GTK XWayland 应用（如 Java Swing、GIMP 等）
# 提供字体、光标主题和 DPI 配置。
#
# 设计说明：
# - GNOME 启用了 xwayland-native-scaling，XWayland 渲染在原始像素空间（4K→3840x2160）
# - Xft/DPI 告诉 GTK 应用真实的显示器 DPI，从而自动放大字体（12pt@156dpi≈26px）
# - Gtk/CursorThemeSize 不受 DPI 影响，需手动设置为 36px（24×1.5）
# - Qt 应用（微信、欧陆词典）不读取 XSETTINGS，需通过 QT_SCALE_FACTOR 分别设置
{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.mySystem.desktop;
  stylixEnabled = config.stylix.enable or false;

  # 名称从 Stylix 读取
  cursorName = if stylixEnabled then config.stylix.cursor.name else "Bibata-Modern-Classic";
  fontName = if stylixEnabled then config.stylix.fonts.sansSerif.name else "HarmonyOS Sans SC Medium";

  # 字体大小保持原值，DPI 负责缩放
  fontSize = if stylixEnabled then config.stylix.fonts.sizes.applications else 12;

  # 光标大小：像素值不受 DPI 影响，直接放大 1.5x
  baseCursorSize = if stylixEnabled then config.stylix.cursor.size else 24;
  cursorSize = builtins.ceil (baseCursorSize * 1.5);

  # DPI: 156 (Xft 格式: DPI×1024)，适配 1080p@14" (~157dpi) + 4K@27" (~163dpi)
  xwaylandDpi = 159744;
in
{
  config = lib.mkIf cfg.enable {
    systemd.user.services.xsettingsd =
      let
        xsettingsdConf = pkgs.writeText "xsettingsd.conf" ''
          Net/ThemeName "Adwaita"
          Gtk/FontName "${fontName}, ${toString fontSize}"
          Gtk/CursorThemeName "${cursorName}"
          Gtk/CursorThemeSize ${toString cursorSize}
          Net/IconThemeName "Papirus"
          Xft/Antialias 1
          Xft/Hinting 1
          Xft/HintStyle "hintslight"
          Xft/RGBA "rgb"
          Xft/DPI ${toString xwaylandDpi}
        '';
      in
      {
        description = "XSettings daemon (font config for XWayland apps like Java Swing)";
        wantedBy = [ "graphical-session.target" ];
        partOf = [ "graphical-session.target" ];
        unitConfig = { };
        serviceConfig = {
          Type = "simple";
          ExecStartPre = "${pkgs.coreutils}/bin/sleep 1";
          ExecStart = "${pkgs.xsettingsd}/bin/xsettingsd -c ${xsettingsdConf}";
          Restart = "on-failure";
          RestartSec = 3;
        };
      };

    environment.systemPackages = [
      pkgs.xsettingsd
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
