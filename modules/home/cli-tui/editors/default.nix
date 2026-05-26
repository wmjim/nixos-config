# 编辑器配置
{ config, pkgs, ... }:

{
  imports = [
    ./helix.nix
    # ./nixvim
    # ./neovim
  ];
}
