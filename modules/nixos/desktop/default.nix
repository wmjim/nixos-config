# 桌面环境模块
{ config, pkgs, ... }:

{
  imports = [
    # ./gnome.nix      # 切换到 niri 后保留文件以备调试回退
    ./niri.nix
    ./fcitx5.nix
  ];
}
