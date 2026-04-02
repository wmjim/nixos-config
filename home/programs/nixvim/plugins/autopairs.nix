{ ... }:
{
  programs.nixvim = {
    # 自动补全括号插件
    # https://github.com/windwp/nvim-autopairs
    plugins.nvim-autopairs = {
      enable = true;
      settings = {
        # 懒加载：仅在插入模式下加载
        event = "InsertEnter";
        # 对特定文件类型禁用
        # disable_filetype = [ "TelescopePrompt" "guihua" ];  
        # 自动跳过闭合括号 - 输入右括号时如果前面已有则跳过
        skip_basic_sym = "";
        # 启用 AST 感知配对
        enable_check_bracket = true;
        # 启用在右括号前添加左括号时自动闭合
        enable_afterquote = true;
      };
    };
  };
}