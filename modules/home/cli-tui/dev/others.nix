{ pkgs, ... }:

{
  # Go 环境
  home.packages = with pkgs; [
    # === bash === 
    bash-language-server # 语言服务器
    shellcheck # 诊断   
    shfmt # 格式化

    # === html/css/json/eslint ===
    vscode-langservers-extracted # 语言服务器

    # === yaml ===
    yaml-language-server # 语言服务器

    # === docker compose ===
    docker-compose-language-service # 语言服务器

    # === lua ===
    lua-language-server # 语言服务器
    stylua # Lua 格式化工具         

    # === Nix ===
    nil


    # === markdown ===
    marksman # 语言服务器
    ltex-ls-plus # 语言服务器，提供拼写和语法检查    

    # === Latex ===
    texlive.combined.scheme-full
    texlab # LaTeX 语言服务器         
  ];
}
