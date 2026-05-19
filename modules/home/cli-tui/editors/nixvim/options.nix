{
  programs.nixvim = {
    globals = {
      # 标识用户是否安装了 Nerd Font 字体，以启用相关图标显示
      # 作为一个开关来控制是否启用图标支持
      have_nerd_font = true;
    };
    opts = {
      # === 行号 ===
      number = true;          # 显示行号
      relativenumber = true;  # 显示相对行号
      cursorline = true;      # 高亮显示光标所在的行

      # === 编码与换行 ===
      fileformat = "unix";     # 使用 Unix 风格的换行符(LF)
      fileformats = [ "unix" "dos" "mac" ]; # 可接受的换行符格式列表
      wrap = false;           # 禁止自动换行

      # === 界面 ===
      termguicolors = true;   # 24 位真彩色支持
      showmode = false;       # 关闭模式显示，由 lualine 状态栏显示

      mouse = "a";            # 启用鼠标支持

      # === 缩进 ===
      tabstop = 2;            # 一个制表符等于 2 个空
      shiftwidth = 2;         # >> 和 << 命令使用 2 个空格进行缩进
      expandtab = true;       # 制表符转换为空格
      autoindent = true;      # 新行继承上一行的缩进
      smartindent = true;     # 智能缩进
      breakindent = true;     # 自动换行时的缩进对齐


      # === 撤销历史 ===
      undofile = true;        # 开启持久化撤销
      # 指定撤销历史文件的存放目录
      undodir.__raw = "os.getenv('HOME') .. '/.vim/undodir'";
      # 在操作系统与Neovim之间同步剪贴板
      clipboard = "unnamedplus";


      # === 搜索 ===
      ignorecase = true;      # 搜索时忽略大小写
      smartcase = true;       # 搜索模式包含大写字母，则区分大小写
      hlsearch = true;        # 设置搜索高亮，普通模式下按<Esc>时清除高亮
      incsearch = true;       # 实时高亮搜索匹配结果
      inccommand = "split";   # 实时预览替换结果，使用水平分屏显示预览


      signcolumn = "yes";     # 始终在左侧保留标记列（用于LSP错误提示）
      updatetime = 250;       # 缩短触发CursorHold事件时间
      # 减少映射序列等待时间
      # 更早显示 which-key 弹窗
      timeoutlen = 300;

      # === 窗口拆分 ===
      splitright = true;      # 水平分窗时，新窗口在右侧打开
      splitbelow = true;      # 垂直分窗时，新窗口在下方打开
      winborder = "rounded";  # 浮动边框样式，使用圆角边框


      list = true;            # 显示空格、制表符等不可见字符
      # NOTE: .__raw 这里表示该字段是原始的Lua代码。
      # Tab 显示为 "» "，行尾显示为 "·"，不间断空格显示为 "␣"
      listchars.__raw = "{ tab = '» ', trail = '·', nbsp = '␣' }";

      # === 滚动与位置 ===
      sidescrolloff = 5;      # 左右滚动时保留 5 列缓冲
      scrolloff = 5;          # 上下滚动时保留 5 行缓冲

    };
  };
}
