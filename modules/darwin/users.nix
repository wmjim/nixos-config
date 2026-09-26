# macOS 用户配置
{ config, pkgs, ... }:

{
  # macOS 用户主要通过 System Preferences 管理
  # nix-darwin 不会实际创建用户，这里声明 home 路径供 home-manager 等模块使用
  users.users.mengw = {
    home = "/Users/mengw";
  };

  # 新版 nix-darwin 要求显式指定 primaryUser，用于 homebrew、system.defaults 等选项
  system.primaryUser = "mengw";

  programs.fish.enable = true;
}
