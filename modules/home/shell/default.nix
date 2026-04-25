# Shell 配置
{ config, pkgs, ... }:

{
  imports = [
    ./fish.nix
    ./starship.nix
    ./tmux.nix
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
      user.email = "meng.w1016@outlook.com";
      init.defaultBranch = "main";
      core.editor = "hx";
      color.ui = "auto";
      push.autoSetupRemote = true;
    };
  };

  # 其他工具
  programs.zoxide.enable = true;
  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;

  # fastfetch 配置
  # 将你的 config.jsonc 放在 ~/.config/fastfetch/ 下
  # home-manager 会自动管理这个目录
  home.file.".config/fastfetch/config.jsonc" = {
    source = ./fastfetch/config.jsonc;
    force = true;
  };
}
