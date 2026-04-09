# Helix 编辑器配置
{ config, pkgs, ... }:

{
  programs.helix = {
    enable = true;
    settings = {
      theme = "monokai_aqua";
      editor = {
        line-number = "relative"; # 相对行号，便于 j/k 跳转
        cursorline = true;        # 高亮当前行
        mouse = true;             # 启用鼠标点击定位
        color-modes = true;       # 不同模式显示不同颜色反馈
        auto-save = true;         # 自动保存文件  
        auto-format = true;       # 保存时自动格式化
        auto-completion = true;   # 自动补全
        auto-pairs = true;        # 自动匹配括号、引号
        bufferline = "multiple";  # 多 buffer 时显示顶部标签栏
        true-color = true;        # 启用 true-color 模式
        rulers = [100];           # 列宽参考线：100 列
        shell = ["bash" "-c"];    # 使用 bash 作为内置终端的 shell

        # 光标形状
        cursor-shape = {
          insert = "bar";         # 插入模式：竖线光标
          normal = "block";       # 普通模式：块状光标
          select = "underline";   # 选择模式：下划线光标
        };

        # 缩进指示线
        indent-guides = {
          render = true;          # 渲染缩进线
          character = "╎";        # 缩进线字符
          skip-levels = 1;        # 跳过最外层缩进线（通常是 0 或 1）
        };

        # 状态栏配置
        statusline = {
          # left: 模式、spinner（加载动画）、文件名、文件修改指示器
          left = ["mode" "spinner" "file-name" "file-modification-indicator"];
          # center: 文件类型
          center = ["file-type"];
          # right: 错误/警告数量、选择信息、行列位置、百分比位置、文件编码、总行数
          right = ["diagnostics" "selections" "position" "position-percentage" "file-encoding" "total-line-numbers"];
          separator = "│";
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };

        # lsp
        lsp = {
          enable = true;                        # 启用 LSP 功能
          display-messages = true;              # 显示 LSP 消息（如错误、警告）
          display-inlay-hints = true;           # 显示类型推断 / 参数名提示
          snippets = true;                      # 启用代码片段      
          auto-signature-help = true;           # 自动显示函数签名
          display-signature-help-docs = true;   # 显示函数签名文档
        };

        # 空格渲染
        whitespace.render = {
          space = "none";       # 不显示空格
          tab = "all";          # 显示所有 tab
          newline = "none";     # 不显示换行符
        };

        # 自定义空格字符
        whitespace.characters = {
          tab = "→";            # tab 显示为 →，更清晰
          tabpad = " ";          # tab 填充显示为空格
        };

        # 自动换行
        soft-wrap = {
          enable = false;       # 代码文件不折行（保持水平滚动）
          wrap-at-text-width = false;
        };

        file-picker.hidden = false; # 不显示隐藏文件
        search.smart-case = true;   # 智能大小写：全小写时忽略大小写，有大写时精确匹配

      };
      keys = {
        # 普通模式
        normal = {
          "C-s" = ":write";                       # ^S 保存文件
          "C-w" = ":buffer-close";                # ^W 关闭当前 buffer
          "C-right" = ":buffer-next";             # ^-> 切换到下一个 buffer
          "C-left"  = ":buffer-previous";         # ^<- 切换到上一个 buffer
        };
        insert = {
          "C-s" = ["normal_mode" ":write"];      # ^S 保存文件并退出 insert 模式
        };
      };
    };
  };
}
