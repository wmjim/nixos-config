# NixOS 本地化配置
{ config, pkgs, ... }:

{
  # 时区
  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "zh_CN.UTF-8";

  # 字体
  fonts.packages = with pkgs; [
    # 等宽字体
    maple-mono.NormalNL-NF-CN-unhinted
    maple-mono.NormalNL-NF-unhinted
    # 中文无衬线/屏幕阅读字体
    lxgw-wenkai-screen
    sarasa-gothic
    # 英文衬线字体
    source-serif-pro          
    noto-fonts-color-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Source Serif Pro" "LXGW WenKai Screen"];
    sansSerif = [ "Sarasa UI SC" ];
    monospace = [ "Maple Mono Normal NL NF CN" ];
    emoji = [ "Noto Color Emoji" ];
  };

  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.hinting.autohint = true;
}
