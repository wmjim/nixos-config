# NixOS 本地化配置
{ config, pkgs, ... }:

{
  # 时区
  time.timeZone = "Asia/Shanghai";

  i18n.defaultLocale = "zh_CN.UTF-8";
  i18n.supportedLocales = [
    "zh_CN.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
  ];
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "zh_CN.UTF-8";
    LC_IDENTIFICATION = "zh_CN.UTF-8";
    LC_MEASUREMENT = "zh_CN.UTF-8";
    LC_MONETARY = "zh_CN.UTF-8";
    LC_NAME = "zh_CN.UTF-8";
    LC_NUMERIC = "zh_CN.UTF-8";
    LC_PAPER = "zh_CN.UTF-8";
    LC_TELEPHONE = "zh_CN.UTF-8";
    LC_TIME = "zh_CN.UTF-8";
  };

  # 字体
  fonts.packages = with pkgs; [
    # 等宽字体
    maple-mono.NormalNL-NF-CN-unhinted
    maple-mono.NormalNL-NF-unhinted
    # 中文无衬线/屏幕阅读字体

    # 英文衬线字体
    source-serif-pro          
    noto-fonts-color-emoji
    pkgs.nur.repos.guanran928.harmonyos-sans
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Source Serif Pro"];
    sansSerif = [ "HarmonyOS Sans SC" ];
    monospace = [ "Maple Mono Normal NL NF CN" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # 字体渲染优化（接近 Ubuntu 的平滑效果）
  fonts.fontconfig.subpixel.rgba = "rgb";
  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.hinting.style = "slight";
  fonts.fontconfig.hinting.autohint = true;
}
