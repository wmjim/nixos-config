# Home Manager 配置（跨平台）
{ config, pkgs, lib, inputs, ... }:

{
  home.stateVersion = "25.11";
  home.enableNixpkgsReleaseCheck = false;

  # NUR overlay (home-manager 独立 nixpkgs 实例需要单独添加)
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  imports = [
    ./shell
    ./editors
    ./dev
    ./apps
    ./desktop
  ];

  # 通用包（跨平台）
  home.packages = with pkgs; [
    fastfetch
    unzip
    tree
    bat
    file
    net-tools
    btop
    yazi
    glow
    hugo
    # 
    pkgs.nur.repos.definfo.cc-switch-cli
  ];
}
