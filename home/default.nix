{ config, pkgs, nixvimModule, ... }:

{
  home.stateVersion = "25.11";
  # 禁用版本不匹配警告
  home.enableNixpkgsReleaseCheck = false;
  imports = [
    nixvimModule
    ./langs
    ./programs/nixvim
    ./programs/fonts.nix
    ./programs/tools.nix
    ./programs/git.nix
    ./programs/fish.nix
    ./programs/ghostty.nix
    ./programs/ai/ai.nix
    ./programs/helix.nix
  ];
}
