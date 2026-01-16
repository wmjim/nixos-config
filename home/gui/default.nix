{ config, pkgs, ... }:

{
  imports = [
    ./wayland.nix
    ./fonts.nix
    ./hyprpanel.nix
    ./wofi.nix
  ];
}
