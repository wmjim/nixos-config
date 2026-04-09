# macOS 笔记本配置
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../hosts/_common/darwin/homebrew.nix
  ];

  # 主机名
  networking.hostName = "macbook";

  # macOS 特定配置
  # 更多配置在 _common/darwin/base.nix

  # 用户包
  homebrew.casks = [
    "visual-studio-code"
    "obsidian"
    "microsoft-edge"
  ];
}
