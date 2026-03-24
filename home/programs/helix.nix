{ pkgs, ... }:

{
  home.packages = [ pkgs.helix ];

  xdg.configFile."helix/config.toml".source = ./helix/config.toml;
  xdg.configFile."helix/languages.toml".source = ./helix/languages.toml;
  xdg.configFile."helix/themes/hardhacker.toml".source = ./helix/hardhacker.toml;
}