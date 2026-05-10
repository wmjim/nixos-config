{ pkgs, ... }:

{
  imports = [
    ./node.nix
    ./python.nix
    ./rust.nix
    ./go.nix
    ./cpp.nix
  ];
}
