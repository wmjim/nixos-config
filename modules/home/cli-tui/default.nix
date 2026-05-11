# CLI/TUI 用户配置
{ pkgs, ... }:

{
  imports = [
    ./shell
    ./editors
    ./dev
    ./apps
  ];
}
