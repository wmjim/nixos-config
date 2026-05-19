{
  config,
  pkgs,
  inputs,
  ...
}:

{
  programs.nixvim = {
    # snacks.nvim 是一个 QoL 插件集合，这里主要使用其 picker 作为模糊搜索工具
    # https://nix-community.github.io/nixvim/plugins/snacks/index.html
    # https://github.com/folke/snacks.nvim
    plugins.snacks = {
      enable = true;
      settings = {
        # 模糊查找器，作为 telescope 的替代
        picker = {
          enabled = true;
        };
        # 大文件检测、文件类型检测等，picker 体验更好
        bigfile.enabled = true;
        quickfile.enabled = true;
        # 输入框 UI（替代 vim.ui.input，类似 dressing.nvim）
        input.enabled = true;
      };
    };

    # 模糊搜索相关键位映射，对齐原 telescope 配置的语义
    # 参考：https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
    keymaps = [
      {
        mode = "n";
        key = "<leader>sh";
        action.__raw = "function() Snacks.picker.help() end";
        options.desc = "[S]earch [H]elp";
      }
      {
        mode = "n";
        key = "<leader>sk";
        action.__raw = "function() Snacks.picker.keymaps() end";
        options.desc = "[S]earch [K]eymaps";
      }
      {
        mode = "n";
        key = "<leader>sf";
        action.__raw = "function() Snacks.picker.files() end";
        options.desc = "[S]earch [F]iles";
      }
      {
        mode = "n";
        key = "<leader>sc";
        action.__raw = "function() Snacks.picker.git_files() end";
        options.desc = "[S]earch [C]ommitted Git Files";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action.__raw = "function() Snacks.picker.pickers() end";
        options.desc = "[S]earch [S]elect Picker";
      }
      {
        mode = "n";
        key = "<leader>sw";
        action.__raw = "function() Snacks.picker.grep_word() end";
        options.desc = "[S]earch current [W]ord";
      }
      {
        mode = "n";
        key = "<leader>sg";
        action.__raw = "function() Snacks.picker.grep() end";
        options.desc = "[S]earch by [G]rep";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action.__raw = "function() Snacks.picker.diagnostics() end";
        options.desc = "[S]earch [D]iagnostics";
      }
      {
        mode = "n";
        key = "<leader>sr";
        action.__raw = "function() Snacks.picker.resume() end";
        options.desc = "[S]earch [R]esume";
      }
      {
        mode = "n";
        key = "<leader>s.";
        action.__raw = "function() Snacks.picker.recent() end";
        options.desc = "[S]earch Recent Files ('.' for repeat)";
      }
      {
        mode = "n";
        key = "<leader><leader>";
        action.__raw = "function() Snacks.picker.buffers() end";
        options.desc = "[ ] Find existing buffers";
      }
      {
        mode = "n";
        key = "<leader>/";
        action.__raw = "function() Snacks.picker.lines() end";
        options.desc = "[/] Fuzzily search in current buffer";
      }
      {
        mode = "n";
        key = "<leader>s/";
        action.__raw = "function() Snacks.picker.grep_buffers() end";
        options.desc = "[S]earch [/] in Open Files";
      }
      {
        mode = "n";
        key = "<leader>sn";
        action.__raw = ''
          function()
            Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
          end
        '';
        options.desc = "[S]earch [N]eovim files";
      }
    ];
  };
}
