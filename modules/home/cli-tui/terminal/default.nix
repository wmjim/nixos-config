# Tmux 和 fastfetch 配置
{ config, pkgs, ... }:

{
  imports = [
    ./tmux
  ];

  home.packages = with pkgs; [
    fastfetch
  ];

  # fastfetch 配置
  home.file.".config/fastfetch/config.jsonc" = {
    source = ./fastfetch/config.jsonc;
    force = true;
  };
}
