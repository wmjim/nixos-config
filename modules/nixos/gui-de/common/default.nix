# 通用 GUI/DE 配置（所有桌面环境共享）
{ ... }:

{
  imports = [
    ./apps.nix
    ./clash.nix
    ./fcitx5.nix
    ./themes.nix
    ./wayland-env.nix
    ./boot.nix
  ];

  # gvfs：Nautilus 回收站、文件挂载、网络共享等功能依赖
  services.gvfs.enable = true;
}
