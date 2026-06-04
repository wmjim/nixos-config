# 文件树插件
# https://github.com/nvim-neo-tree/neo-tree.nvim
# https://nix-community.github.io/nixvim/plugins/neo-tree/index.html
{ ... }:
{
  programs.nixvim = {
    plugins.neo-tree = {
      enable = true;

      settings = {
        add_blank_line_at_top = false;

        window = {
          width = 30;
          mappings."<space>" = "none";
        };

        filesystem = {
          bind_to_cwd = false;
          group_empty_dirs = true; # 将空目录合并显示
          hijack_netrw = true; # 接管 Neovim 内置的 netrw
          follow_current_file = {
            enabled = true;
            leave_dirs_open = true;
          };
        };

        default_component_configs = {
          indent = {
            with_expanders = true;
            expander_collapsed = "󰅂";
            expander_expanded = "󰅀";
            expander_highlight = "NeoTreeExpander";
          };

          git_status.symbols = {
            added = " "; # 新增
            modified = "  "; # 修改
            deleted = "󱂥 "; # 删除
            renamed = "󰑕 "; # 重命名
            untracked = " "; # 未跟踪
            unstaged = " "; # 未暂存
            staged = "󰩍 "; # 已暂存
            ignored = "  "; # 忽略
            conflict = "  "; # 冲突
          };
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>e";
        action = "<cmd>Neotree toggle<cr>";
        options.desc = "资源管理器";
        options.silent = true;
      }
    ];
  };
}
