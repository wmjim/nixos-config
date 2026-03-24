{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";
  imports = [
    ./langs
    ./programs/fonts.nix
    ./programs/tools.nix
    ./programs/git.nix
    ./programs/fish.nix
    ./programs/ghostty.nix
    ./programs/ai/ai.nix
    ./programs/nvim.nix
  ];
}
