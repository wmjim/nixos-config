{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.cli.editors.neovim;
  editorsCfg = config.mengw.cli.editors;
  cliCfg = config.mengw.cli;

  # neovim 配置文件实际存放的目录（在仓库中手动管理）
  nvimConfigPath = "${config.home.homeDirectory}/nixos-config/modules/home/cli-tui/editors/nvim";
in
{
  options.mengw.cli.editors.neovim.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Neovim 编辑器";
  };

  config = lib.mkIf (cfg.enable && editorsCfg.enable && cliCfg.enable) {
    # 安装 neovim（不用 programs.neovim，因为要自己管理配置）
    home.packages = [
      pkgs.neovim
    ];

    # 将 ~/.config/nvim 软链接到仓库中的配置目录
    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimConfigPath;
  };
}