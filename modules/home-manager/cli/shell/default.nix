# Shell 配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.shell;
  cliCfg = config.mengw.cli;
in
{
  options.mengw.cli.shell.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Shell 配置（终端工具、Git 等）";
  };

  imports = [
    ./fish.nix
    ./starship.nix
  ];

  config = lib.mkIf (cfg.enable && cliCfg.enable) {
    # 快捷键速查表
    xdg.configFile."DankMaterialShell/cheatsheets/" = {
      source = ./../cheatsheets;
      recursive = true;
      force = true;
    };

    # 终端工具
    home.packages = with pkgs; [
      eza
      zoxide
      bat
      fzf
      ripgrep
      fd
      jq
      yq
      sysstat
      tldr
    ];

    # Git
    programs.git = {
      enable = true;
      settings = {
        user.name = "meng.wang";
        user.email = "meng.w1016@outlook.com";
        init.defaultBranch = "main";
        core.editor = "hx";
        color.ui = "auto";
        push.autoSetupRemote = true;
      };
    };
  };
}
