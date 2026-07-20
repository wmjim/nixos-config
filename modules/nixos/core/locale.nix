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

  # Stylix 为其 fonts.*.package 引用的字体自动调用 fonts.packages，
  # 此处的字体包仅限 Stylix 未覆盖的补充字体。
  fonts.packages = with pkgs; [
    maple-mono.NormalNL-NF-unhinted  # Maple Mono 非 CN 变体（Stylix 使用 CN 变体）
    lxgw-wenkai                       # 霞鹜文楷，中文衬线补充字体
  ];

  # fontconfig 字体族映射由 Stylix 统一管理（stylix.fonts.*），
  # 此处仅保留渲染参数（Stylix 不覆盖这些）。
  fonts.fontconfig.subpixel.rgba = "rgb";
  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.hinting.style = "slight";
  fonts.fontconfig.hinting.autohint = true;
}
