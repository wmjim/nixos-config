{ pkgs, ... }:

{
  imports = [
    ./nodejs.nix
    ./python.nix
    ./rust.nix
    ./go.nix
    ./cpp.nix
  ];
}
