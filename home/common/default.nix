{ config, pkgs, ... }:

{
  imports = [
    ./kitty.nix
    ./git.nix
    ./devel.nix
    ./shell.nix
    ./fish.nix
    ./helix.nix
    ./clash.nix
  ];
}
