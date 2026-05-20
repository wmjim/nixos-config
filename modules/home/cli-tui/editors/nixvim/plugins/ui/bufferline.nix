{
  config,
  pkgs,
  inputs,
  ...
}:

{
  programs.nixvim = {
    # 启用 bufferline 插件，提供类似 IDE 的标签页栏
    plugins.bufferline.enable = true;

    # 延迟加载：在文件打开后再加载，缩短启动时间
    plugins.bufferline.lazyLoad = {
      enable = true;
      settings = {
        event = ["User LazyFile"];
      };
    };

    # 插件核心配置
    plugins.bufferline.settings = {
      options = {
        # ── 外观 ──
        # 当前 buffer 的指示器样式：underline（下划线）或 icon（图标）
        indicator = {
          style = "underline";
          # icon = "▎";
          # style = "icon";
        };

        buffer_close_icons = "⨉ ";  # 单个 buffer 的关闭图标
        close_icon = "⨉  ";       # 右侧"关闭全部"图标
        modified_icon = "●";      # 未保存文件的修改标记
        left_trunc_marker = "";  # 左侧截断标记（buffer 过多时显示）
        right_trunc_marker = ""; # 右侧截断标记

        # ── 诊断 ──
        # 显示 LSP 诊断信息，来源可选 "nvim_lsp" | "coc" | "default"
        diagnostics = "nvim_lsp";
        # 自定义诊断图标：错误用 ，警告用 
        diagnostics_indicator = ''
          function(count, level)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
          end
        '';

        # ── 侧边栏偏移 ──
        # 为 Neo-tree 等侧边栏留出空间，避免标签栏被遮挡
        offsets = [
          {
            filetype = "neo-tree";
            text = "Bug Hell Portal";
            text_align = "left";
          }
        ];

        # ── 行为 ──
        max_average_window_width = 100;    # 平均窗口宽度上限，防止 buffer 过多时过度挤压
        show_buffer_close_icons = true;    # 在每个 buffer 上显示关闭图标
        show_close_icon = true;            # 显示右侧"关闭全部"图标
        show_tab_indicators = true;        # 显示 Tabline 上方的指示器
        enforce_regular_tabs = true;       # 强制使用常规标签页样式
        always_show_bufferline = true;     # 即使只有一个 buffer 也显示标签栏
        # buffer 排序方式：
        # "insert_after_current" | "id" | "extension" | "relative_directory" | "tabs"
        sort_by = "insert_after_current";
        # buffer 编号显示："none" | "ordinal" | "buffer_id" | "custom"
        numbers = "none";
      };
    };

    # ── 快捷键 ──
    # 所有快捷键均在 Normal 模式下生效，前缀为 <leader>b
    keymaps = [
      # 导航
      {
        mode = "n";
        key = "]b";
        action = "<cmd>BufferLineCycleNext<cr>";
        options.desc = "切换下一个缓冲区";
      }
      {
        mode = "n";
        key = "[b";
        action = "<cmd>BufferLineCyclePrev<cr>";
        options.desc = "切换上一个缓冲区";
      }
      {
        mode = "n";
        key = "<leader>bb";
        action = "<CMD>e #<CR>";
        options.desc = "快速切换缓冲区（切换到上一个编辑的文件）";
      }
      {
        mode = "n";
        key = "<leader>bf";
        action = "<cmd>BufferLinePick<cr>";
        options.desc = "交互式选择并跳转缓冲区";
      }

      # 管理
      {
        mode = "n";
        key = "<leader>bd";
        action = "<cmd>bdelete<cr>";
        options.desc = "删除当前缓冲区";
      }
      {
        mode = "n";
        key = "<leader>bo";
        action = "<cmd>BufferLineCloseOthers<cr>";
        options.desc = "关闭其他所有缓冲区";
      }
      {
        mode = "n";
        key = "<leader>bp";
        action = "<cmd>BufferLineTogglePin<cr>";
        options.desc = "固定/取消固定当前缓冲区";
      }
      {
        mode = "n";
        key = "<leader>bP";
        action = "<Cmd>BufferLineGroupClose ungrouped<CR>";
        options.desc = "关闭所有未固定的缓冲区";
      }
    ];
  };
}