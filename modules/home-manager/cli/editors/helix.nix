# Helix 编辑器配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.editors.helix;
  editorsCfg = config.mengw.cli.editors;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.editors.helix.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Helix 编辑器";
  };

  config = lib.mkIf (cfg.enable && editorsCfg.enable && cliCfg.enable) {
    programs.helix = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ./helix/config.toml);
      languages = builtins.fromTOML (builtins.readFile ./helix/languages.toml);
    };
  };
}
