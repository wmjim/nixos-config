{ pkgs, config, ... }:

{
  programs.neovim = {
    enable = true;
    # 启用 Node.js 和 Python 支持
    withNodeJs = true;
    withPython3 = true;
    # 设置别名
    viAlias = true;
    vimAlias = true;
  };

  # home.file.neovim-config = {
  #   target = ".config/nvim";
  #   source = ./config.kdl;
  # };
}