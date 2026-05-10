# CLI 应用配置
{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    claude-code
  ];

  home.sessionVariables = {
    # 插件安装目录
    TMPDIR = "$HOME/.tmp";
  };
}
