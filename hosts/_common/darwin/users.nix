# macOS 用户配置
{ config, pkgs, ... }:

{
  # macOS 用户主要通过 System Preferences 管理
  # nix-darwin 不会实际创建用户，这里声明 home 路径供 home-manager 等模块使用
  users.users.mengw = {
    home = "/Users/mengw";
  };

  programs.fish.enable = true;
}
