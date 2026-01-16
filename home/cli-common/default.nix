{ config, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./shell.nix
    ./fish.nix
    ./helix.nix
    ./zellij.nix
    ./devel.nix
  ];
}
