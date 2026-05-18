# 通用 GUI/DE 配置（所有桌面环境共享）
{ ... }:

{
  imports = [
    ./apps.nix
    ./clash.nix
    ./fcitx5.nix
    ./plymouth.nix
    ./portal.nix
    ./themes.nix
  ];
}
