# 媒体 / 录屏 / 截图
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    mpv # 视频播放器
    splayer # 音乐播放器
    obs-studio # 录屏
    snipaste # 截图工具
    picgo # 图床管理
    calibre
    freetube # YouTube 客户端
    bilibili # 哔哩哔哩
  ];
}
