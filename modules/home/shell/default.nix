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
    fzf          # 模糊搜索
    ripgrep      # grep 替代
    fd           # find 替代
    jq           # JSON 处理
    yq           # YAML 处理
  ];

  # Git
  programs.git = {
    enable = true;
    settings = {
      user.name = "meng.wang";
      user.email = "meng.wang@example.com";  # 请修改为你的邮箱
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  # 其他工具
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;
}
