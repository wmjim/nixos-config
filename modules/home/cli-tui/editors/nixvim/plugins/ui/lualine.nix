{
  config,
  pkgs,
  inputs,
  ...
}:

{
  programs.nixvim = {
    plugins.lualine = {
      enable = true;
      settings = {
        options = {
          # 特定文件类型下隐藏 lualine
          disabled_filetypes = {
            # 以下文件类型不显示底部状态栏
            statusline = [
              "dashboard"         # 启动页
              "alpha"             # 另一种启动页
              "starter"           # 另一种启动页
              "neo-tree"          # neo-tree 侧边栏
              "mini-files"        # mini-files 悬浮文件树
              "dap-repl"          # 调试 REPL
            ];
            # 以下文件类型不显示顶部 winbar
            winbar = [
              "aerial"            # 大纲
              "dap-repl"          # 调试 REPL
              "neotest-summary"   # 测试总结
            ];
          };
          # 区块之间分隔符设为空，保持简洁
          section_separators = "";
          # 组件之间分隔符设为空，保持简洁
          component_separators = "";
          # 启用全局状态栏，所有窗口共用一个状态栏
          globalstatus = true;
        };
        sections = {
          lualine_c = [
            {
              __unkeyed-1.__raw = ''
                function()
                  local ok, harpoon = pcall(require, "harpoon")
                  if not ok then
                    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":~:.")
                  end
                  local list = harpoon:list()
                  local current = vim.fn.expand("%:p")
                  if current == "" then
                    return ""
                  end
                  for i = 1, list:length() do
                    local item = list:get(i)
                    if item then
                      local item_value = item.value or ""
                      -- 统一用绝对路径比较，避免相对路径和绝对路径不匹配
                      if item_value == current or vim.fn.fnamemodify(item_value, ":p") == current then
                        return "󰃀 " .. vim.fn.fnamemodify(current, ":~:.")
                      end
                    end
                  end
                  return vim.fn.fnamemodify(current, ":~:.")
                end
              '';
            }
          ];
        };
      };
    };
  };
}
