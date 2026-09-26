{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.dev.node;
  devCfg = config.mengw.cli.dev;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.dev.node.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Node.js 开发环境";
  };

  config = lib.mkIf (cfg.enable && devCfg.enable && cliCfg.enable) {
    # Node.js 环境（版本交给 fnm，shell 初始化见 cli/shell/fish.nix）
    home.packages = with pkgs; [
      fnm
      yarn
      pnpm
      typescript-language-server # typescript/js/tsx/jsx lsp
      prettier # JavaScript/TypeScript/JSON/Markdown/YAML 格式化器
    ];
  };
}
