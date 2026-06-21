# 浏览器
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    brave
  ];
}
