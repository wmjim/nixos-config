# GUI/桌面环境用户配置
{ lib, config, ... }:
let
  cfg = config.mengw.gui;
in
{
  options.mengw.gui.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 GUI/桌面环境用户配置";
  };

  imports = [
    ./themes
    ./apps
    ./niri
    ./fcitx5.nix
    ./vscode.nix
    ./hide-ghost-apps.nix
  ];
}
