# 开发工具
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zed-editor # 代码编辑器
  ];
}
