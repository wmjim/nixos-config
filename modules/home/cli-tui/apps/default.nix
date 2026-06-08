# CLI 应用配置
{ config, pkgs, ... }:

{
  imports = [
    ./yazi
    # ./tmux
    ./zellij
  ];

  home.packages = with pkgs; [
    fastfetch
    lazydocker
    lazygit
    claude-code
    codex
    unzip
    tree
    file
    net-tools
    # nvtopPackages.nvidia
    btop
    duf
    glow
    hugo
  ];

  home.sessionVariables = {
    # claude 插件安装目录
    TMPDIR = "$HOME/.tmp";
  };

  # fastfetch 配置
  home.file.".config/fastfetch/config.jsonc" = {
    source = ./fastfetch/nixos-01.jsonc;
    force = true;
  };
}
