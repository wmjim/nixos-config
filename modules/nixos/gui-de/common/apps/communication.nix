# 通讯工具
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.desktop.common.apps.communication;
  appsCfg = config.mengw.desktop.common.apps;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;

  # 微信 (Qt6) 强制退回到 XWayland (X11) 模式，通过 xcb 渲染，
  # 并补齐传统 XIM 输入法通道变量，使 Fcitx5 通过 D-Bus 在沙箱内打通输入。
  wechat-scaled = pkgs.symlinkJoin {
    name = "wechat-scaled";
    paths = [ pkgs.wechat ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/wechat \
        --unset WAYLAND_DISPLAY \
        --set QT_QPA_PLATFORM "xcb" \
        --set QT_SCALE_FACTOR 1.25 \
        --set GTK_IM_MODULE "fcitx" \
        --set QT_IM_MODULE "fcitx" \
        --set XMODIFIERS "@im=fcitx"
    '';
  };
in
{
  options.mengw.desktop.common.apps.communication.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用通讯工具";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && commonCfg.enable && desktopCfg.enable) {
    environment.systemPackages = with pkgs; [
      discord
      telegram-desktop
      wechat-scaled # 微信（已修复分数缩放）
      qq     # qq
    ];
  };
}
