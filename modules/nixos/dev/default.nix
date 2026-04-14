# 开发工具模块
{ config, pkgs, ... }:

{
  # Docker（可选）
  # virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    # 开发工具
    lazydocker
    lazygit
  ];
}
