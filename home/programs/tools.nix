{ pkgs, ... }:

{
  # 通用开发工具
  home.packages = with pkgs; [
    # neovim
    git
    wget
    tree
    bat
    fastfetch
    btop
    lazydocker     # Docker 图形界面管理工具
    lazygit        # Git 图形界面管理工具
    yazi           # 终端文件管理器

  ];
}
