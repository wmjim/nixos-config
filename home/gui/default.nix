{ config, pkgs, ... }:

{
  imports = [
    ./wayland.nix
    ./fonts.nix
    ./waybar.nix
    ./wofi.nix
  ];
}
