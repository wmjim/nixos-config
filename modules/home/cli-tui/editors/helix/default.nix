# Helix 编辑器配置
{ config, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ./config.toml);
    languages = builtins.fromTOML (builtins.readFile ./languages.toml);
  };
}
