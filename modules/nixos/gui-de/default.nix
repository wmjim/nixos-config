# 桌面环境模块
{ ... }:

{
  imports = [
    ./portal.nix
    # ./gnome.nix      # 切换到 niri 后保留文件以备调试回退
    ./niri/niri.nix
    ./clash.nix
    ./fcitx5.nix
  ];
}
