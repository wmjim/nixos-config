# Home Manager 配置（跨平台）
{ config
, pkgs
, lib
, inputs
, ...
}:

{
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false;


  imports = [
    ./cli-tui
  ];
}
