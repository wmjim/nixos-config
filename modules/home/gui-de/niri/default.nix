# niri 窗口管理器 — 用户级配置文件部署
{ config, pkgs, lib, ... }: let
  # niri 配置目录路径：~/.config/niri/config.kdl
  # 使用 mkOutOfStoreSymlink 加速调试
  niriConfigPath = "${config.home.homeDirectory}/nixos-config/modules/home/gui-de/niri/config";
in
{
  imports = [
    ./noctalia.nix
  ];

  # 使用符号链接绑定整个 niri 配置目录，修改后无需 rebuild 即可生效
  xdg.configFile."niri".source = config.lib.file.mkOutOfStoreSymlink niriConfigPath;
}
