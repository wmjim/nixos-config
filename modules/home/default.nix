# Home Manager 配置（跨平台）
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.stateVersion = "26.05";
  home.enableNixpkgsReleaseCheck = false;


  imports = [
    ./cli-tui
    # 需要 GUI/DE 的主机在 flake.nix 中额外导入 ./gui-de
  ];
}
