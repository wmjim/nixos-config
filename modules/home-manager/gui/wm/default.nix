# Niri 窗口管理器 — 用户级配置文件部署
{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.mengw.gui.wm;
  guiCfg = config.mengw.gui;
  niriConfigPath = "${config.home.homeDirectory}/nixos-config/modules/home-manager/gui/wm/config";
in
{
  options.mengw.gui.wm.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Niri 窗口管理器用户级配置";
  };

  imports = [
    ./noctalia.nix
  ];

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    xdg.configFile."niri".source = config.lib.file.mkOutOfStoreSymlink niriConfigPath;
  };
}
