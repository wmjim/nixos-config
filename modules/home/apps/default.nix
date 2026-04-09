# 应用配置
{ config, pkgs, ... }:

{
  imports = [
    ./ghostty.nix
  ];

  # 应用配置（跨平台）
  home.packages = with pkgs; [
    # 这里添加跨平台的 GUI 应用
    claude-code
  ];

  home.sessionVariables = {
    # 插件安装目录
    TMPDIR = "$HOME/.tmp";
  };
}
