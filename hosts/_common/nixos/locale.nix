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
    noto-fonts-cjk-serif      # 思源宋体
    # 英文衬线字体
    source-serif-pro          
    noto-fonts-color-emoji
    # 中文无衬线回退
    noto-fonts-cjk-sans       # 思源黑体
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Source Serif Pro" "Noto Serif CJK SC" ];
    sansSerif = [ "Noto Sans Mono CJK SC" ];
    monospace = [ "Maple Mono Normal NL NF CN" ];
    emoji = [ "Noto Color Emoji" ];
  };

  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.hinting.autohint = true;

  # 光标主题
  environment.variables.XCURSOR_THEME = "Adwaita";
}
