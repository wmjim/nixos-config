{ pkgs, ... }:

{
  # Node.js 环境
  home.packages = with pkgs; [
    nodejs_24
    yarn
    pnpm
    typescript-language-server # typescript/js/tsx/jsx lsp
    prettier # JavaScript/TypeScript/JSON/Markdown/YAML 格式化器
  ];
}
