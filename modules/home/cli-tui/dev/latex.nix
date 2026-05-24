{ pkgs, ... }:

{
  # Go 环境
  home.packages = with pkgs; [
    texlive.combined.scheme-full
  ];
}
