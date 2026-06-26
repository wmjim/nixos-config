# CLI/TUI 用户配置
{ lib, config, ... }:
{
  imports = [
    ./shell
    ./editors
    ./dev
    ./apps
  ];
}
