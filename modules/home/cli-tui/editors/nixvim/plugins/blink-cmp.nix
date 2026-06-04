{ config
, pkgs
, inputs
, ...
}:

{
  programs.nixvim = {
    # 代码片段引擎
    plugins.luasnip = {
      enable = true;
    };

    # 一组针对不同语言的预配置代码片段
    plugins.friendly-snippets = {
      enable = true;
    };

    # luasnip 运行时依赖
    extraLuaPackages = ps: [
      ps.jsregexp
    ];

    # 自动补全引擎
    # https://nix-community.github.io/nixvim/plugins/blink-cmp/index.html
    # blink.cmp 自带 LSP 集成，会自动向 nvim-lspconfig 注入补全 capabilities，
    # 因此无需再启用 cmp-nvim-lsp。
    plugins.blink-cmp = {
      enable = true;

      settings = {
        # 启用代码片段，并通过 luasnip 展开
        snippets = {
          preset = "luasnip";
        };

        # 补全源：LSP、路径、代码片段、缓冲区
        sources = {
          default = [
            "lsp"
            "path"
            "snippets"
            "buffer"
          ];
        };

        # 按键映射，沿用习惯的 Tab/S-Tab 选择、CR 确认、C-Space 触发
        # https://cmp.saghen.dev/configuration/keymap.html
        keymap = {
          preset = "default";

          "<Tab>" = [
            "select_next"
            "snippet_forward"
            "fallback"
          ];
          "<S-Tab>" = [
            "select_prev"
            "snippet_backward"
            "fallback"
          ];
          "<Down>" = [
            "select_next"
            "fallback"
          ];
          "<Up>" = [
            "select_prev"
            "fallback"
          ];
          "<CR>" = [
            "accept"
            "fallback"
          ];
          "<C-Space>" = [
            "show"
            "show_documentation"
            "hide_documentation"
          ];
          "<C-b>" = [
            "scroll_documentation_up"
            "fallback"
          ];
          "<C-f>" = [
            "scroll_documentation_down"
            "fallback"
          ];
          "<C-l>" = [
            "snippet_forward"
            "fallback"
          ];
          "<C-h>" = [
            "snippet_backward"
            "fallback"
          ];
        };

        # 补全菜单与文档窗口
        completion = {
          # 输入时自动弹出菜单
          trigger = {
            show_on_keyword = true;
            show_on_trigger_character = true;
          };

          # 不预选第一项，避免回车误确认
          list = {
            selection = {
              preselect = false;
              auto_insert = true;
            };
          };

          menu = {
            border = "rounded";
            draw = {
              treesitter = [ "lsp" ];
            };
          };

          # 悬停时自动显示文档
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
            window = {
              border = "rounded";
            };
          };

          # 输入时高亮匹配的字符
          ghost_text = {
            enabled = true;
          };
        };

        # 函数签名提示窗口
        signature = {
          enabled = true;
          window = {
            border = "rounded";
          };
        };

        # 使用 Rust 实现的模糊匹配，性能更好
        fuzzy = {
          implementation = "prefer_rust_with_warning";
        };

        # 显示补全项类型图标
        appearance = {
          nerd_font_variant = "mono";
          use_nvim_cmp_as_default = false;
        };
      };
    };
  };
}
