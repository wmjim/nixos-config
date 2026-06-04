{
  programs.nixvim = {
    globals = {
      # 将 <space> 设置为前导键
      mapleader = " "; # 全局前导键
      maplocalleader = " "; # 缓冲区前导键
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>pv";
        action = "vim.cmd.Ex";
      }
      {
        mode = "v";
        key = "J";
        action = ">+1<CR>gv=gv";
        options = {
          desc = "下移一行";
        };
      }
      {
        mode = "v";
        key = "K";
        action = "<-2<CR>gv=gv";
        options = {
          desc = "上移一行";
        };
      }
      {
        mode = "n";
        key = "<C-d>";
        action = "<C-d>zz";
        options = {
          desc = "Page down and center cursor";
        };
      }
      {
        mode = "n";
        key = "<C-u>";
        action = "<C-u>zz";
        options = {
          desc = "Page up and center cursor";
        };
      }
      {
        mode = "n";
        key = "n";
        action = "nzzzv";
        options = {
          desc = "Go to next search and center cursor";
        };
      }
      {
        mode = "n";
        key = "N";
        action = "Nzzzv";
        options = {
          desc = "Go to previous search and center cursor";
        };
      }
      {
        mode = "n";
        key = "<leader>ws";
        action = "<cmd>split<CR><C-w><down>";
        options = {
          desc = "Create horizontal split and move to it";
        };
      }
      {
        mode = "n";
        key = "<leader>wv";
        action = "<cmd>vsplit<CR><C-w><right>";
        options = {
          desc = "Create vertical split and move to it";
        };
      }
      {
        mode = "n";
        key = "<leader>wh";
        action = "<C-w><left>";
        options = {
          desc = "Move to left split";
        };
      }
      {
        mode = "n";
        key = "<leader>wj";
        action = "<C-w><down>";
        options = {
          desc = "Move to below split";
        };
      }
      {
        mode = "n";
        key = "<leader>wk";
        action = "<C-w><up>";
        options = {
          desc = "Move to above split";
        };
      }
      {
        mode = "n";
        key = "<leader>wl";
        action = "<C-w><right>";
        options = {
          desc = "Move to right split";
        };
      }
      {
        mode = "n";
        key = "U";
        action = "<C-r>";
        options = {
          desc = "Undo";
        };
      }
      {
        mode = "i";
        key = "jk";
        action = "<Esc>";
        options = {
          desc = "Exit insert mode";
        };
      }
      {
        mode = "n";
        key = "<C-f>";
        action = "vim.lsp.buf.format";
        options = {
          desc = "LSP format";
        };
      }
      {
        mode = "n";
        key = "<leader>o";
        action = "o<Esc>k";
        options = {
          desc = "Add blank line below and move cursor";
        };
      }
      {
        mode = "n";
        key = "<leader>O";
        action = "O<Esc>k";
        options = {
          desc = "Add blank line above and move cursor";
        };
      }
      {
        mode = "n";
        key = "<leader>gs";
        action = "<cmd>Git<CR>";
        options = {
          desc = "Git";
        };
      }
      {
        mode = "n";
        key = "<leader>gp";
        action = "<cmd>Git push<CR>";
        options = {
          desc = "Git push";
        };
      }
      {
        mode = "n";
        key = "<leader>ga";
        action = "<cmd>Git add .<CR>";
        options = {
          desc = "Git add all files";
        };
      }
      {
        mode = "n";
        key = "<C-A-h>";
        action.__raw = "require('smart-splits').resize_left";
        options = {
          desc = "Resize split to the left";
        };
      }
      {
        mode = "n";
        key = "<C-A-j>";
        action.__raw = "require('smart-splits').resize_down";
        options = {
          desc = "Resize split down";
        };
      }
      {
        mode = "n";
        key = "<C-A-k>";
        action.__raw = "require('smart-splits').resize_up";
        options = {
          desc = "Resize split up";
        };
      }
      {
        mode = "n";
        key = "<C-A-l>";
        action.__raw = "require('smart-splits').resize_right";
        options = {
          desc = "Resize split to the right";
        };
      }
      {
        mode = "n";
        key = "<C-h>";
        action.__raw = "require('smart-splits').move_cursor_left";
        options = {
          desc = "Move to the left split";
        };
      }
      {
        mode = "n";
        key = "<C-j>";
        action.__raw = "require('smart-splits').move_cursor_down";
        options = {
          desc = "Move to the below split";
        };
      }
      {
        mode = "n";
        key = "<C-k>";
        action.__raw = "require('smart-splits').move_cursor_up";
        options = {
          desc = "Move to the above split";
        };
      }
      {
        mode = "n";
        key = "<C-l>";
        action.__raw = "require('smart-splits').move_cursor_right";
        options = {
          desc = "Move to the right split";
        };
      }
    ];
  };
}
