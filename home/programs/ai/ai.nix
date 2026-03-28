{ pkgs, ... }:

{
  # 通用开发工具
  home.packages = with pkgs; [
    claude-code
  ];
  home.sessionVariables = {
    # 插件安装目录
    TMPDIR = "$HOME/.tmp";
  };
}