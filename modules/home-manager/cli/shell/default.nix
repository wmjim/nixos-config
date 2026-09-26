# Shell 配置
# 门控：目录导入即生效（mengw.cli.enable 控制整个 CLI 层），无中间层开关；
# 单独关闭某个叶子（如 fish）用该叶子自己的 enable 选项。
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cliCfg = config.mengw.cli;
in
{
  imports = [
    ./fish.nix
  ];

  config = lib.mkIf cliCfg.enable {
    # 快捷键速查表
    xdg.configFile."cheatsheets/" = {
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
      gh
      git-repo
      direnv
    ];

    # Git
    programs.git = {
      enable = true;
      settings = {
        user.name = "meng.wang";
        user.email = "meng.w1016@outlook.com";
        init.defaultBranch = "main";
        core.editor = "nvim";
        color.ui = "auto";
        push.autoSetupRemote = true;
      };
    };
  };
}
