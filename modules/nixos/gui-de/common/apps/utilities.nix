# 系统工具 / 实用程序
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.desktop.common.apps.utilities;
  appsCfg = config.mengw.desktop.common.apps;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;

  # 欧陆词典（自带的 Qt 5.15 只有 xcb 平台插件，需要强制回退到 XWayland）
  eudic-fixed = pkgs.symlinkJoin {
    name = "eudic-fixed";
    paths = [ pkgs.eudic ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/eudic \
        --unset WAYLAND_DISPLAY \
        --set QT_QPA_PLATFORM "xcb" \
        --set QT_SCALE_FACTOR 1.5 \
        --set GTK_IM_MODULE "fcitx" \
        --set QT_IM_MODULE "fcitx" \
        --set XMODIFIERS "@im=fcitx" \
        --unset QT_STYLE_OVERRIDE \
        --set XKB_CONFIG_ROOT "${pkgs.xkeyboard_config}/share/X11/xkb" \
        --set GST_PLUGIN_SYSTEM_PATH_1_0 ""
    '';
  };
in
{
  options.mengw.desktop.common.apps.utilities.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用系统工具和实用程序";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && commonCfg.enable && desktopCfg.enable) {
    environment.systemPackages = with pkgs; [
      ddcutil # 显示器亮度调节
      mission-center # 系统监控器
      file-roller # 解压工具
      papers # 文档查看器
      gnome-text-editor # 轻量文本编辑
      qview # 图片查看器
      nautilus # 文件管理器
      logisim-evolution # 数字电路设计
      localsend # 跨平台文件共享
      cc-switch # AI 管理工具
      cherry-studio
      baidupcs-go # 百度网盘
      eudic-fixed # 欧陆词典（修复 Wayland 兼容性）
    ];
  };
}
