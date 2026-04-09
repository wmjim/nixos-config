# NixOS 本地化配置
{ config, pkgs, ... }:

{
  # 时区
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  # 字体
  fonts.packages = with pkgs; [
    maple-mono.NF
    maple-mono.NF-CN
    lxgw-wenkai-screen
    source-serif-pro
    noto-fonts-color-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Source Serif Pro" "LXGW WenKai Screen" ];
    sansSerif = [ ];
    monospace = [ "Maple Mono NF" ];
    emoji = [ "Noto Color Emoji" ];
  };

  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.hinting.autohint = true;

  # 光标主题
  environment.variables.XCURSOR_THEME = "Adwaita";
}
