# macOS 用户配置
{ config, pkgs, ... }:

{
  # macOS 用户主要通过 System Preferences 管理
  # 这里只配置 shell
  programs.fish.enable = true;
}
