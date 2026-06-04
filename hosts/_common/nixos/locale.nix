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



  # 启用默认字体包，补充基础 Unicode 覆盖
  fonts.enableDefaultPackages = true;
  # Flatpak 兼容，Flatpak 应用可访问系统字体
  fonts.fontDir.enable = true;

  fonts.packages = with pkgs; [
    # 等宽字体
    maple-mono.NormalNL-NF-CN-unhinted
    maple-mono.NormalNL-NF-unhinted
    # 中文无衬线/屏幕阅读字体
    # 中文衬线字体 (霞鹜文楷 + 霞鹜文楷等宽)
    lxgw-wenkai
    # 英文衬线字体
    source-serif-pro
    noto-fonts-color-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Source Serif Pro" "LXGW WenKai" ];
    sansSerif = [ "HarmonyOS Sans SC" ];
    monospace = [ "Maple Mono Normal NL NF" "LXGW WenKai Mono" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # 字体渲染优化（接近 Ubuntu 的平滑效果）
  fonts.fontconfig.subpixel.rgba = "rgb";
  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.hinting.style = "slight";
  fonts.fontconfig.hinting.autohint = true;
}
