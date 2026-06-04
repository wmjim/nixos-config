# WhichKey 通过在您输入时弹出窗口显示可用的按键绑定，帮助您记住 Neovim 的键位映射
# https://github.com/folke/which-key.nvim
# https://nix-community.github.io/nixvim/plugins/which-key/index.html

{ config
, pkgs
, inputs
, ...
}:

{
  programs.nixvim = {
    plugins.which-key = {
      enable = true;
      settings = {
        # 按键后延迟 200 毫秒弹出
        delay = 200;
        # 自动展开分组，显示组内的具体按键映射，而不是只显示分组名称
        expand = 1;
        # 禁用 which-key 的启动通知
        notify = false;
        preset = "modern"; # 显示风格
        # 替换按键名称为更易读的形式
        replace = {
          desc = [
            [
              "<space>"
              "Space"
            ]
            [
              "<leader>"
              "Space"
            ]
            [
              "<[cC][rR]>"
              "Return"
            ]
            [
              "<[tT][aA][bB]>"
              "Tab"
            ]
            [
              "<[bB][sS]>"
              "Backspace"
            ]
          ];
        };

        # 自定义按键分组
        # __unkeyed-1 按键前缀
        # group       分组名称
        # icon        分组图标（Nerd Font）
        # mode        适用模式（normal、visual等）
        spec = [
          {
            __unkeyed-1 = "<leader>f";
            group = "文件查找";
            icon = "󰈞";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>c";
            group = "lsp操作";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>a";
            group = "AI";
            icon = "󱚣";
            mode = [ "n" "v" ];
          }

          {
            __unkeyed-1 = "<leader>d";
            group = "调试";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>g";
            group = "Git";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>t";
            group = "终端操作";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>m";
            group = "标记";
            icon = "󰃀";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>T";
            group = "主题切换";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>b";
            group = "缓冲区操作";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>w";
            group = "窗口移动";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>h";
            group = "Git Hunk/代码块修改";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader><tab>";
            group = "tab管理";
            icon = "󰓩";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>e";
            group = "资源管理器";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>H";
            group = "帮助查询";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>D";
            group = "诊断浮窗";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>x";
            group = "问题查看";
            icon = "";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>q";
            group = "退出编辑器";
            icon = "󰩈";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>p";
            group = "文档内容预览(typ/md)";
            icon = "󰈈";
            mode = "n";
          }

          {
            __unkeyed-1 = "<leader>o";
            group = "专注面板";
            icon = "";
            mode = "n";
          }
        ];
      };
    };
  };
}
