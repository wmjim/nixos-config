# Clash Verge 配置
{ config, pkgs, ... }:

{
  programs.clash-verge = {
    enable = true;
    autoStart = true;
    tunMode = true;
    serviceMode = true;
  };
}
