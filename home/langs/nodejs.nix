{ pkgs, ... }:

{
  # Node.js 环境
  home.packages = with pkgs; [
    nodejs_24
    yarn
    pnpm
    nodePackages.typescript-language-server  # TypeScript/JavaScript LSP
    prettierd             # JavaScript/TypeScript/JSON/Markdown/YAML 格式化器
  ];
}
