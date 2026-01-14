{ config, pkgs, ... }:

{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    maple-mono.NF-CN-unhinted
  ];

}
