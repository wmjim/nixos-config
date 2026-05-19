{ ... }:
{
  imports = [
    ./ui
    ./editor  # 提供文件浏览器、搜索与替换、模糊查找、Git 集成等功能
    ./autopairs.nix
    ./autotag.nix
    ./blankline.nix
    ./conform.nix
    ./fugitive.nix
    ./gitsigns.nix
    ./lsp.nix
    ./blink-cmp.nix
    ./oil.nix
    ./rainbow-delimiters.nix
    ./smart-splits.nix
    ./sort.nix
    ./surround.nix
    ./todo.nix
    ./snacks.nix
    ./treesitter.nix
  ];
}