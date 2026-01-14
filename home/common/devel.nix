{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    tree
    impala
    nodejs
    ripgrep
    net-tools
    claude-code
  ];
}
