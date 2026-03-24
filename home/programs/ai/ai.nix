{ pkgs, ... }:

{
  # 通用开发工具
  home.packages = with pkgs; [
    claude-code
  ];
}