return {
  "saghen/blink.cmp",
  -- 使用最新 release 版本
  version = "*",
  -- 进入插入模式时延迟加载
  event = "InsertEnter",

  opts = {
    -- 补全菜单中显示的候选项数量
    completion = {
      menu = {
        draw = {
          -- 补全来源图标
          treesitter = { " " },
          lsp = { " " },
          buffer = { "﬘ " },
          path = { " " },
          snippets = { " " },
        },
      },
    },

    -- 快捷键映射（使用默认预设）
    keymap = { preset = "default" },

    -- 补全来源
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },
  },
}
