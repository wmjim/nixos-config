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

  # NUR overlay (home-manager 独立 nixpkgs 实例需要单独添加)
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  imports = [
    ./cli-tui
  ];
}
