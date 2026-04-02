{ config, pkgs, ... }:

{
  imports = [ ./plugins ];

  programs.nixvim = {
    enable = true;
    version.enableNixpkgsReleaseCheck = false;
    colorschemes.vscode.enable = true;  # 主题
    plugins.lualine.enable = true;          # 状态栏插件
    defaultEditor = true;
    globals = {
      mapleader = " ";          # 主 leader 键：空格
      maplocalleader = " ";     # 局部 leader 键：空格
      have_nerd_font = true;    # 是否使用 nerd 字体
    };

    opts = {
      # 编辑设置
      expandtab = true;   # 空格替代制表符
      smartindent = true; # 智能缩进
      shiftwidth = 2;     # 缩进宽度：2 个空格
      

      # 界面设置
      number = true;         # 显示行号
      relativenumber = true; # 显示相对行号
      cursorline = true;     # 当前行高亮
      ruler = true;          # 显示当前行号和列号
      scrolloff = 10;        # 滚动偏移量：10 行
      signcolumn = "yes";    # 始终在左侧保留标记列（用于LSP错误提示）
      wildmenu = true;       # 命令行自动补全


      # 文件处理
      backupcopy = "yes";   # 备份文件策略：创建备份文件
      autochdir = true;     # 自动切换到文件所在目录
      undofile = true;      # 启用撤销文件


      # 搜索设置
      ignorecase = true;  # 搜索时忽略大小写
      smartcase = true;   # 如果搜索模式包含大写字母，则区分大小写 
      incsearch = true;   # 实时更新显示匹配结果
      hlsearch = true;    # 高亮搜索结果
      wrapscan = true;    # 在搜索过程中，环绕到文本的开头/末尾继续搜索
      # 当输入替换命令，vim 会在一个分割窗口中实时显示替换的结果
      inccommand = "split";  # 水平分割显示预览
      
      
      # 其它设置
      mouse = "a";          # 启用鼠标支持
      showmode = false;     # 不显示当前模式(状态栏已显示)
      clipboard = "unnamedplus"; # 启用剪贴板支持
      breakindent = true;   # 段落缩进
      splitright = true;    # 水平分割时，新窗口在右侧
      splitbelow = true;    # 垂直分割时，新窗口在下方
      updatetime = 250;     # Vim 的更新时间
      timeoutlen = 300;     # 键盘映射的响应时间
    };
    keymaps = [
      # {
      #   mode = "n";
      #   key = "<leader>pv";
      #   action = "vim.cmd.Ex";
      # }
    ];

    # 插件列表
    plugins = {
      # 自动根据文件调整缩进宽度和制表符缩进
      # https://nix-community.github.io/nixvim/plugins/sleuth/index.html
      sleuth = {
        enable = true;
      };

      # 智能注释
      # https://nix-community.github.io/nixvim/plugins/comment/index.html
      comment = {
        enable = true;
      };
      # 注释中高亮 todo、notes 等关键词
      # https://nix-community.github.io/nixvim/plugins/todo-comments/index.html
      todo-comments = {
        enable = true;
      };
    };

    # 要安装的额外 vim 插件列表
    extraPlugins = with pkgs.vimPlugins; [
      # 图标插件 - 用于在文件树中显示文件图标
      nvim-web-devicons
    ];
  };
}
