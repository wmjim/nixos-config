# 快速访问 Neovim 中的文件和标记
# https://github.com/ThePrimeagen/harpoon/
# https://nix-community.github.io/nixvim/plugins/harpoon/index.html
{ ... }:
{
  programs.nixvim = {
    plugins.harpoon = {
      enable = true;
      settings = {
        default = {
          display.__raw = ''
            function(list_item)
              if list_item.context and list_item.context.name then
                return list_item.context.name .. "\t→\t" .. list_item.value
              end
              return list_item.value
            end
          '';
        };
      };
    };

    # options.silent = true，静默执行，保持界面干净
    keymaps = [
      {
        mode = "n";
        key = "<leader>ma";
        action.__raw = ''function() local harpoon = require("harpoon") harpoon:list():add() end'';
        options.desc = "文件添加标记";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>mA";
        action.__raw = ''
          function()
            local harpoon = require("harpoon")
            vim.ui.input({ prompt = "标记备注: " }, function(name)
              if name and name ~= "" then
                harpoon:list():add({ value = vim.fn.expand("%:p"), context = { name = name, row = vim.fn.line("."), col = vim.fn.col(".") } })
              end
            end)
          end
        '';
        options.desc = "添加标记(备注)";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>md";
        action.__raw = ''
          function()
            local harpoon = require("harpoon")
            local list = harpoon:list()
            local current = vim.fn.expand("%:p")
            for i = 1, list:length() do
              local item = list:get(i)
              if item then
                local item_value = item.value or ""
                if item_value == current or vim.fn.fnamemodify(item_value, ":p") == current then
                  table.remove(list.items, i)
                  list._length = list._length - 1
                  return
                end
              end
            end
          end
        '';
        options.desc = "移除文件标记";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>mD";
        action.__raw = ''function() require("harpoon"):list():clear() end'';
        options.desc = "移除所有标记";
        options.silent = true;
      }
      {
        mode = "n";
        key = "<leader>mm";
        action.__raw = ''function() local harpoon = require("harpoon"); harpoon.ui:toggle_quick_menu(harpoon:list()) end'';
        options.desc = "文件标记菜单";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>mp";
        action.__raw = ''function() require("harpoon"):list():prev() end'';
        options.desc = "跳转上一个标记";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>mn";
        action.__raw = ''function() require("harpoon"):list():next() end'';
        options.desc = "跳转下一个标记";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>m1";
        action.__raw = ''function() require("harpoon"):list():select(1) end'';
        options.desc = "跳转标记1";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>m2";
        action.__raw = ''function() require("harpoon"):list():select(2) end'';
        options.desc = "跳转标记2";
        options.silent = true;  
      }

      {
        mode = "n";
        key = "<leader>m3";
        action.__raw = ''function() require("harpoon"):list():select(3) end'';
        options.desc = "跳转标记3";
        options.silent = true;
      }

      {
        mode = "n";
        key = "<leader>m4";
        action.__raw = ''function() require("harpoon"):list():select(4) end'';
        options.desc = "跳转标记4";
        options.silent = true;
      }
    ];
  };
}
