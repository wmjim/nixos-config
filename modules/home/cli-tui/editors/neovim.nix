{ config, pkgs, ... }:
let
  # neovim 配置文件实际存放的目录（在仓库中手动管理）
  nvimConfigPath = "${config.home.homeDirectory}/nixos-config/modules/home/cli-tui/editors/nvim";
in
{
  # 安装 neovim（不用 programs.neovim，因为要自己管理配置）
  home.packages = [
    pkgs.neovim
  ];

  # 将 ~/.config/nvim 软链接到仓库中的配置目录
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimConfigPath;
}