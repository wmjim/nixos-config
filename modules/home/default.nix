# Home Manager 配置（跨平台）
{ config, pkgs, lib, ... }:

{
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;

  imports = [
    ./shell
    ./editors
    ./dev
    ./apps
  ];

  # 通用包（跨平台）
  home.packages = with pkgs; [
    unzip
    tree
    bat
    fastfetch
    btop
    yazi
    glow
    hugo
  ];
}
