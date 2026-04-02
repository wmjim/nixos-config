{ ... }:
{
  programs.nixvim = {
    # 缩进指南线插件
    plugins.indent-blankline = {
      enable = true;
      settings = {
        indent = {
          smart_indent_cap = true;
          char = " ";
          tab_char = " ";
        };
        scope = {
          enabled = true;
          char = "│";
        };
      };
    };
  };
}