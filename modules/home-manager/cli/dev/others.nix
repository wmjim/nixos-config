{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.dev.others;
  devCfg = config.mengw.cli.dev;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.dev.others.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用其他语言的开发环境（LSP、格式化工具等）";
  };

  config = lib.mkIf (cfg.enable && devCfg.enable && cliCfg.enable) {
    # 其他语言开发工具
    home.packages = with pkgs; [
    # === bash === 
    bash-language-server # bash lsp
    shellcheck # 诊断   
    shfmt # 格式化

    fish-lsp # fish lsp

    # === kdl ===
    kdlfmt # kdl fmt


    # === html/css/json/eslint ===
    vscode-langservers-extracted # html/json/css/scss/js/ts lsp
    eslint

    # === yaml ===
    yaml-language-server # yaml lsp

    # === docker compose ===
    docker-compose-language-service # docker lsp

    # === lua ===
    lua-language-server # lua lsp
    stylua # Lua 格式化工具         

    # === Nix ===
    nil # nix lsp
    nixfmt # nix fmt


    # === markdown ===
    marksman # markdown lsp
    ltex-ls-plus # markdown lsp，提供拼写和语法检查    

    # === Latex ===
    # texlive.combined.scheme-full
    # texlab # LaTeX 语言服务器
    ];
  };
}
