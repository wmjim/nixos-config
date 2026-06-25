{ config, pkgs, ... }:
let

  nvimPath = "{config.home.homeDirectory}/nixos-config/module/home/cli-tui/editor/neovim";

in
{
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimPath;
}
