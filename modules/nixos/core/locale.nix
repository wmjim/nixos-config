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
    LC_CTYPE = "en_US.UTF-8";
  };

  # 启用默认字体包
  fonts.enableDefaultPackages = true;
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    maple-mono.NormalNL-NF-CN-unhinted
    maple-mono.NormalNL-NF-unhinted
    pkgs.nur.repos.guanran928.harmonyos-sans
    lxgw-wenkai
    source-serif-pro
    noto-fonts-color-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Source Serif Pro" "LXGW WenKai" ];
    sansSerif = [ "HarmonyOS Sans SC" ];
    monospace = [ "Maple Mono Normal NL NF" "LXGW WenKai Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };

  fonts.fontconfig.subpixel.rgba = "rgb";
  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.hinting.style = "slight";
  fonts.fontconfig.hinting.autohint = true;
}
