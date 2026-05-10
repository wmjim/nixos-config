# XDG Portal 桌面基础设施
# 从 hosts/_common/nixos/base.nix 提取，仅桌面环境需要
{ pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  };
}
