# GUI/桌面环境用户配置
# 仅 desktop/laptop 主机导入此模块
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

  config = {
    # 强制使用英文 XDG 用户目录名（不受系统 locale 影响）
    xdg.userDirs = {
      enable = true;
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";
      templates = "${config.home.homeDirectory}/Templates";
      publicShare = "${config.home.homeDirectory}/Public";
    };
  };

  imports = [
    ./themes
    ./apps
    ./wm
    ./fcitx5.nix
    ./vscode.nix
    ./hide-ghost-apps.nix
  ];
}
