{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    tree
    impala
    nodejs
    ripgrep
    net-tools
    firefox
    claude-code
  ];
}
