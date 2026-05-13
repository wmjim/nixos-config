# CLI 应用配置
{ config, pkgs, ... }:

{
  imports = [
      ./tmux
      ./zellij.nix
    ];

  home.packages = with pkgs; [
    fastfetch
    lazydocker
    lazygit
    claude-code
    unzip
    tree
    file
    net-tools
    nvtopPackages.nvidia
    btop
    yazi
    glow
    hugo
    # pkgs.nur.repos.definfo.cc-switch-cli
  ];

  home.sessionVariables = {
    # claude 插件安装目录
    TMPDIR = "$HOME/.tmp";
  };

  # fastfetch 配置
  home.file.".config/fastfetch/config.jsonc" = {
    source = ./fastfetch/config.jsonc;
    force = true;
  };
}
