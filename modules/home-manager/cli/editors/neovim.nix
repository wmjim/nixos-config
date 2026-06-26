# Neovim 编辑器配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.editors.neovim;
  editorsCfg = config.mengw.cli.editors;
  cliCfg = config.mengw.cli;

  nvimConfigPath = "${config.home.homeDirectory}/nixos-config/modules/home-manager/cli/editors/nvim";
in
{
  options.mengw.cli.editors.neovim.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Neovim 编辑器";
  };

  config = lib.mkIf (cfg.enable && editorsCfg.enable && cliCfg.enable) {
    home.packages = [ pkgs.neovim ];
    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimConfigPath;
  };
}
