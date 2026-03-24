{ pkgs, ... }:

{
  home.packages = [ pkgs.neovim ];
  home.file."./.config/nvim/" = {
    source = ./config;
    recursive = true;
  };
}
