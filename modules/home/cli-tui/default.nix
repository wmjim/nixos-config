# CLI/TUI 用户配置
{ pkgs, ... }:

{
  imports = [
    ./shell
    ./terminal
    ./editors
    ./dev
    ./apps
  ];

  # 通用 CLI/TUI 包（跨平台）
  home.packages = with pkgs; [
    unzip
    tree
    file
    net-tools
    btop
    yazi
    glow
    hugo
    pkgs.nur.repos.definfo.cc-switch-cli
  ];
}
