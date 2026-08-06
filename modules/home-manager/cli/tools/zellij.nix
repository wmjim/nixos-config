# Zellij — 终端复用器
{ lib, config, ... }:
let
  cfg = config.mengw.cli.tools.zellij;
  toolsCfg = config.mengw.cli.tools;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.tools.zellij.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Zellij 终端复用器";
  };

  config = lib.mkIf (cfg.enable && toolsCfg.enable && cliCfg.enable) {
    programs.zellij = { enable = true; };

    home.file.zellij-config = {
      target = ".config/zellij/config.kdl";
      source = ./zellij/config.kdl;
    };
  };
}
