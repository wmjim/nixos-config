# 通讯工具
{ pkgs, ... }:

let
  # 微信 (Qt6, 内部强制 X11/xcb) 在 niri 的分数缩放下无法正确识别 DPI，
  # 通过 QT_SCALE_FACTOR 显式设置缩放比例，匹配 DP-2 显示器的 1.50x。
  wechat-scaled = pkgs.symlinkJoin {
    name = "wechat-scaled";
    paths = [ pkgs.wechat ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/wechat \
        --set QT_SCALE_FACTOR 1.25 \
        --set QT_IM_MODULE "fcitx"
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    discord
    telegram-desktop
    feishu # 飞书
    wechat-scaled # 微信（已修复分数缩放）
    qq     # qq
    wemeet # 腾讯会议
  ];
}
