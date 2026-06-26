{ pkgs, ... }:

{
  # Go 环境
  home.packages = with pkgs; [
    go
    gopls # go lsp
  ];
}
