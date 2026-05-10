# macOS 笔记本配置
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../modules/darwin                     # macOS GUI 管理（系统默认值 + Homebrew casks）
  ];

  # 主机名
  networking.hostName = "macbook";
}
