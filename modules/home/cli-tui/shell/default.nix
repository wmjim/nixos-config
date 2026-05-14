# Shell 配置
{ config, pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./starship.nix
  ];

  # 终端工具
  home.packages = with pkgs; [
    eza          # ls 替代
    zoxide       # cd 替代
    bat          # cat 替代，带语法高亮和分页
    fzf          # 模糊搜索
    ripgrep      # grep 替代
    fd           # find 替代
    jq           # JSON 处理
    yq           # YAML 处理
    sysstat      # iostat/sar 等系统监控工具（tmux 主题脚本依赖）
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
}
