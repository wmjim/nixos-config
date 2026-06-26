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
    # 快捷键速查表 — 供终端查询和 DMS 共用
    xdg.configFile."DankMaterialShell/cheatsheets/" = {
      source = ../cheatsheets;
      recursive = true;
      force = true;
    };

    # 终端工具
    home.packages = with pkgs; [
      eza # ls 替代
      zoxide # cd 替代
      bat # cat 替代，带语法高亮和分页
      fzf # 模糊搜索
      ripgrep # grep 替代
      fd # find 替代
      jq # JSON 处理
      yq # YAML 处理
      sysstat # iostat/sar 等系统监控工具（tmux 主题脚本依赖）
      tldr # 命令简明手册
      fzf
      eza
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
