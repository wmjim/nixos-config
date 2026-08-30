# 系统工具 / 实用程序
{ lib, config, pkgs, myLib, ... }:
let
  cfg = config.mengw.gui.apps.utilities;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;

  eudic-fixed = myLib.wrapQtXWayland {
    inherit pkgs;
    pkg = pkgs.eudic;
    # 窗口 WM_CLASS 为 eudic，而桌面文件 ID 是 eusoft-eudic，需补充
    # StartupWMClass 让 GNOME Shell / Dash to Panel 正确显示应用图标
    startupWMClass = "eudic";
    extraWrapArgs = ''
      --unset QT_STYLE_OVERRIDE \
      --set XKB_CONFIG_ROOT "${pkgs.xkeyboard_config}/share/X11/xkb" \
      --set GST_PLUGIN_SYSTEM_PATH_1_0 ""
    '';
  };
in
{
  options.mengw.gui.apps.utilities.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用系统工具和实用程序";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    home.packages = with pkgs; [
      ddcutil
      file-roller
      papers
      gnome-text-editor
      mission-center        # 图形化任务中心
      foliate               # eBook阅读器
      wike                  # 桌面版Wiki阅读器
      parabolic             # yt-dlp图形化前端
      planify               # 任务管理器
      gapless               # 本地音乐播放器
      xunlei-uos            # 迅雷
      qview                 # 图片查看
      nautilus
      logisim-evolution
      localsend
      eudic-fixed
    ];
  };
}
