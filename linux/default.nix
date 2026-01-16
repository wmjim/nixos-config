{ config, pkgs, ... }:

{
  # Home Manager 必须设置的选项
  home.username = "mengw";
  home.homeDirectory = "/home/mengw";
  home.stateVersion = "25.11";

  # Linux 特定配置
  home.sessionVariables = {
    # Linux 特定环境变量
    BROWSER = "xdg-open";
  };

  # Linux 相关包
  home.packages = with pkgs; [
    # 可以添加 Linux 特定工具
  ];
}
