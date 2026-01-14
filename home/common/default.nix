{ config, pkgs, ... }:

{
  imports = [
    ./terminal.nix
    ./editors.nix
    ./devel.nix
    ./shell.nix
    ./helix.nix
  ];
}
