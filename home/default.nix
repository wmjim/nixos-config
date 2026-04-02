{ config, pkgs, nixvimModule, ... }:

{
  home.stateVersion = "25.11";
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
