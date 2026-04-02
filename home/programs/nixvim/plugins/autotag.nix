{ ... }:
{
  programs.nixvim = {
    # 自动闭合与重命名 HTML/JSX 元素插件
    # https://github.com/tronikelis/ts-autotag.nvim
    plugins.ts-autotag = {
      enable = true;
    };
  };
}