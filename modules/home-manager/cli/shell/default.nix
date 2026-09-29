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
      eza # ls 的现代替代
      zoxide # cd 的现代替代
      bat # cat 的现代替代
      ripgrep # grep 的现代替代
      fd # find 的现代替代
      dust # du 的现代替代
      tldr # man 的现代替代
      jq # json 处理器
      yq # yaml/xml/toml 处理器
      fzf # 命令行模糊查找
      sysstat # Linux的性能监控工具集（如sar、iostat和pidstat）
      gh # github cli
      git-repo # android 的仓库管理工具
      direnv # 管理环境的 shell 扩展
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
