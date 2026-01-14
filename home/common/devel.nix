{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    tree
    impala
    nodejs
    ripgrep
    net-tools
    firefox
    claude-code

    # LSP 服务器（为 Helix 提供自动补全）
    nil          # Nix LSP
    clang        # C/C++ LSP (clangd)
    rust-analyzer # Rust LSP
    python312Packages.python-lsp-server # Python LSP
    nodePackages.typescript-language-server # TypeScript/JavaScript LSP
    taplo        # TOML LSP

    # 格式化工具
    nixpkgs-fmt  # Nix 格式化器
    clang-tools  # C/C++ 格式化器 (包含 clang-format)
    black        # Python 格式化器
    prettierd    # JavaScript/TypeScript/JSON/Markdown/YAML 格式化器
  ];
}
