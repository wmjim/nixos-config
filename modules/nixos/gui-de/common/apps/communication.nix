# 通讯工具
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    discord
    telegram-desktop
    feishu # 飞书
    wemeet # 腾讯会议
  ];
}
