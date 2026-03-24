# Ghostty 终端配置（仅 NixOS 桌面）
{ config, pkgs, ... }:

{
  # 安装 ghostty
  environment.systemPackages = with pkgs; [
    ghostty
  ];
  # 字体配置
  fonts.fontconfig.enable = true;
}
