# Zellij — 终端复用器
{ lib, config, ... }:
let
  cfg = config.mengw.cli.apps.zellij;
  appsCfg = config.mengw.cli.apps;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.apps.zellij.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Zellij 终端复用器";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && cliCfg.enable) {
    # 启用 home-manager 的 Zellij 模块（安装二进制 + 管理配置文件）
    programs.zellij = { enable = true; };

    home.file.zellij-config = {
      target = ".config/zellij/config.kdl";
      source = ./config.kdl;
    };

    # home.file.zellij-layouts = {
    #   target = ".config/zellij/layouts/default.kdl";
    #   source = ./layouts/default.kdl;
    # };
  };
}
