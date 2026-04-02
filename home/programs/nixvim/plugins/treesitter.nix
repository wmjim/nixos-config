{
  config,
  pkgs,
  inputs,
  ...
}:

{
  programs.nixvim = {
    # 突出显示、编辑和导航代码
    # https://nix-community.github.io/nixvim/plugins/treesitter/index.html
    plugins.treesitter.enable = true;
  };
}