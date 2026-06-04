# Treesitter
# 现代语法高亮
# 增量解析
# 代码折叠
# 语义感知
{ config
, pkgs
, inputs
, ...
}:

{
  programs.nixvim = {
    # https://nix-community.github.io/nixvim/plugins/treesitter/index.html
    plugins.treesitter = {
      enable = true;

      # 可自定义安装的语法解析器列表，默认安装所有语法解析器
      # grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      #   c
      #   cpp
      #   rust
      #   bash
      #   lua
      #   luadoc
      #   make
      #   markdown
      #   nix
      #   regex
      #   toml
      #   vim
      #   vimdoc
      #   xml
      #   yaml
      #   html
      #   json
      # ];

      # 语法高亮
      highlight = {
        enable = true;

        # 额外启用 Vim 的正则高亮，兼容某些特殊语法
        #  additional_vim_regex_highlighting = [
        #    "ruby"
        #  ];
      };

      # 基于 treesitter 的智能缩进
      # treesitter 的 indent 模块质量参差不齐，某些语言可能不如自带的缩进规则
      # indent = {
      #   enable = true;
      # };

      # 基于 treesitter 的代码折叠
      # folding = {
      #   enable = true;
      # };
    };
  };
}
