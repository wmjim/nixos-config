{ config, pkgs, ... }:

{
  # Helix 编辑器配置
  programs.helix = {
    enable = true;

    # 基础设置
    settings = {
      # 默认主题
      theme = "catppuccin_frappe";

      # 编辑器核心配置
      editor = {
        color-modes = true;               # 启用颜色模式（根据主题自动适配亮/暗色）
        cursorline = true;                # 高亮当前光标所在行
        line-number = "relative";         # 行号显示：相对行号  
        mouse = true;                     # 启用鼠标鼠标支持
        middle-click-paste = false;       # 允许中键粘贴
        scroll-lines = 3;                 # 滚动行数  
        shell = ["fish" "-c"];            # Shell 集成（用于外部命令）
        auto-completion = true;           # 启用自动补全功能
        completion-timeout = 5;           # 设置补全超时时间为 5 s
        preview-completion-insert = true; # 允许预览并插入补全内容
        completion-trigger-len = 2;       # 设置补全触发长度为 2 个字符
        auto-save = true;                 # 启用自动保存功能
        auto-info = true;                 # 启用自动显示类型信息
        true-color = true;                # 启用真彩色终端支持
        undercurl = true;                 # 启用下划线样式
        bufferline = "multiple";          # 显示多个 buffer
        soft-wrap.enable = true;          # 启用软换行（长行自动折行显示）
        end-of-line-diagnostics = "hint"; # 在行尾显示诊断信息（如错误/警告图标）
        # 在光标行内联显示诊断（仅显示 warning 及以上级别）
        inline-diagnostics.cursor-line = "warning";
        # 光标形状配置
        cursor-shape = {
          normal = "block";               # 普通模式：块状光标
          insert = "bar";                 # 插入模式：条形光标
          select = "underline";           # 选择模式：下划线光标
        };
        # 缩进指引配置
        indent-guides = {
          render = true;                  # 启用缩进指引
          character = "│";                # 指引字符
          skip-levels = 1;                # 跳过层级
        };

        # 侧边栏配置（显示诊断信息、行号、diff）
        gutters = [
          "diagnostics"  # LSP 诊断信息
          "line-numbers" # 行号
          "diff"         # Git diff
        ];

        # 状态栏配置
        statusline = {
          # 左侧：模式、文件信息
          left = [
            "mode"                          # 编辑模式
            "file-name"                     # 文件名
            "spinner"                       # LSP 加载指示器
            "read-only-indicator"           # 只读指示器
            "file-modification-indicator"   # 修改指示器
          ];
          # 中间：文件位置百分比
          center = ["position-percentage"];
          # 右侧：版本控制、诊断、编码等
          right = [
            "diagnostics"        # 诊断错误/警告
            "selections"         # 选择数量
            "register"           # 寄存器
            "file-type"          # 文件类型
            "file-line-ending"   # 文件行尾符
            "version-control"    # Git 分支等信息
            "file-encoding"      # 文件编码
            "position"           # 光标位置
          ];
          # 分隔符
          separator = "│";
          # 模式显示文本
          mode.normal = "NORMAL";
          mode.insert = "INSERT";
          mode.select = "SELECT";
        };

        # LSP（语言服务器）配置
        lsp = {
          display-messages = true;              # 显示 LSP 消息
          display-inlay-hints = true;           # 显示内联提示
          display-signature-help-docs = true;   # 显示签名帮助文档
          snippets = true;                      # 支持代码片段
          goto-reference-include-declaration = true; # 跳转引用时包含声明
        };

        # 文件选择器配置
        file-picker = {
          hidden = false;           # 不显示隐藏文件
          follow-symlinks = true;   # 跟随符号链接
          deduplicate-links = true; # 去重链接
          parents = true;           # 包含父目录
          ignore = true;            # 忽略 .ignore 文件
          git-ignore = true;        # 遵守 .gitignore
          git-global = true;        # 遵守全局 git ignore
          git-exclude = true;       # 遵守 .gitexclude
        };

        # 缩进启发式算法（使用 Tree-sitter）
        indent-heuristic = "tree-sitter";
      };

      # 快捷键配置
      keys = {
        # 普通模式快捷键
        normal = {
          # 翻页快捷键
          C-b = ["page_cursor_up"];    # Ctrl+B: 向上翻页
          C-f = ["page_cursor_down"];  # Ctrl+F: 向下翻页
          C-u = ["half_page_up"];      # Ctrl+U: 向上半页
          C-d = ["half_page_down"];    # Ctrl+D: 向下半页

          # Space 键映射（Leader 键）
          space = {
            space = "file_picker";  # Space+Space: 文件选择器
            w = ":w";               # Space+W: 保存
            q = ":q";               # Space+Q: 退出
            Q = ":q!";              # Space+Shift+Q: 强制退出
            f = ":format";          # Space+F: 格式化代码
            e = ["extend_to_line_bounds" "delete_selection" "paste_after"]; # Space+E: 复制行
            c = ["toggle_comments"]; # Space+C: 切换注释
            "." = ["repeat_last_motion"]; # Space+.: 重复上一次操作
          };

          # 键映射
          "#" = "toggle_line_comments";
        };

        # 选择模式快捷键
        select = {
          space = {
            space = "file_picker";
            w = ":w";
            q = ":q";
            Q = ":q!";
            f = ":format";
            e = ["extend_to_line_bounds" "delete_selection" "paste_after"];
            c = ["toggle_comments"];
          };

          "#" = "toggle_line_comments";
        };
      };
    };

    # 语言配置（格式化器等）
    languages = {
      language = [
        # Nix 语言
        {
          name = "nix";
          formatter = {
            command = "nixpkgs-fmt";
          };
          auto-format = true;
        }

        # Rust 语言
        {
          name = "rust";
          auto-format = true; # 使用内置的 rustfmt
        }

        # C 语言
        {
          name = "c";
          formatter = {
            command = "clang-format";
            args = ["-i"];
          };
          auto-format = true;
        }

        # C++ 语言
        {
          name = "cpp";
          formatter = {
            command = "clang-format";
            args = ["-i"];
          };
          auto-format = true;
        }

        # Python 语言
        {
          name = "python";
          formatter = {
            command = "black";
          };
          auto-format = true;
        }

        # JavaScript 语言
        {
          name = "javascript";
          formatter = {
            command = "prettier";
            args = ["--parser" "javascript"];
          };
          auto-format = true;
        }

        # TypeScript 语言
        {
          name = "typescript";
          formatter = {
            command = "prettier";
            args = ["--parser" "typescript"];
          };
          auto-format = true;
        }

        # JSON 语言
        {
          name = "json";
          formatter = {
            command = "prettier";
            args = ["--parser" "json"];
          };
          auto-format = true;
        }

        # Markdown 语言
        {
          name = "markdown";
          formatter = {
            command = "prettier";
            args = ["--parser" "markdown"];
          };
          auto-format = true;
        }

        # TOML 语言
        {
          name = "toml";
          formatter = {
            command = "taplo";
            args = ["format" "-"];
          };
          auto-format = true;
        }

        # YAML 语言
        {
          name = "yaml";
          formatter = {
            command = "prettier";
            args = ["--parser" "yaml"];
          };
          auto-format = true;
        }
      ];
    };
  };

  # Catppuccin Frappe 主题配置
  xdg.configFile."helix/themes/catppuccin_frappe.toml".text = ''
    # 继承默认主题
    inherits = "default"

    # Catppuccin Frappe 调色板（26 种和谐的颜色）
    [palette]
    rosewater = "#f2d5cf"  # 玫瑰水色
    flamingo = "#eebebe"   # 火烈鸟色
    pink = "#f4b8e4"       # 粉色
    mauve = "#ca9ee6"      # 藤紫色
    red = "#e78284"        # 红色
    maroon = "#ea999c"     # 栗色
    peach = "#ef9f76"      # 桃色
    yellow = "#e5c890"     # 黄色
    green = "#a6d189"      # 绿色
    teal = "#81c8be"       # 青色
    sky = "#99d1db"        # 天蓝色
    sapphire = "#85c1dc"   # 蓝宝石色
    blue = "#8caaee"       # 蓝色
    lavender = "#babbf1"    # 薰衣草色
    text = "#c6d0f5"       # 文本色
    subtext1 = "#b5bfe2"   # 次文本 1
    subtext0 = "#a5adce"   # 次文本 0
    overlay2 = "#949cbb"   # 叠加层 2
    overlay1 = "#838ba7"   # 叠加层 1
    overlay0 = "#737994"   # 叠加层 0
    surface2 = "#626880"   # 表面 2
    surface1 = "#51576d"   # 表面 1
    surface0 = "#414559"   # 表面 0
    base = "#303446"       # 基础色（背景）
    mantle = "#292c3c"     # 地幔色
    crust = "#232634"      # 地壳色

    # UI 元素配色
    ["ui.background"]
    bg = "base"

    ["ui.text"]
    fg = "text"

    ["ui.text.focus"]
    fg = "text"
    bg = "surface0"

    ["ui.cursor"]
    fg = "base"
    bg = "rosewater"

    ["ui.cursor.primary"]
    fg = "base"
    bg = "rosewater"

    ["ui.cursor.match"]
    fg = "peach"
    bg = "surface1"

    ["ui.cursorline.primary"]
    bg = "surface0"

    ["ui.cursorline.secondary"]
    bg = "surface0"

    ["ui.selection"]
    bg = "surface1"

    ["ui.selection.primary"]
    bg = "overlay0"

    ["ui.linenr"]
    fg = "surface1"

    ["ui.linenr.selected"]
    fg = "lavender"

    ["ui.statusline"]
    fg = "subtext1"
    bg = "mantle"

    ["ui.statusline.inactive"]
    fg = "overlay0"
    bg = "mantle"

    ["ui.statusline.normal"]
    fg = "base"
    bg = "lavender"

    ["ui.statusline.insert"]
    fg = "base"
    bg = "green"

    ["ui.statusline.select"]
    fg = "base"
    bg = "flamingo"

    ["ui.bufferline"]
    fg = "subtext0"
    bg = "mantle"

    ["ui.bufferline.active"]
    fg = "base"
    bg = "mauve"

    ["ui.bufferline.background"]
    bg = "mantle"

    ["ui.popup"]
    fg = "text"
    bg = "surface0"

    ["ui.window"]
    fg = "overlay0"
    bg = "surface0"

    ["ui.help"]
    fg = "subtext0"
    bg = "surface0"

    ["ui.debug"]
    fg = "text"
    bg = "surface0"

    ["ui.debug.breakpoint"]
    fg = "base"
    bg = "red"

    ["ui.debug.active"]
    fg = "base"
    bg = "yellow"

    ["ui.menu"]
    fg = "overlay2"
    bg = "surface0"

    ["ui.menu.selected"]
    fg = "text"
    bg = "overlay0"

    ["ui.menu.scroll"]
    fg = "overlay0"
    bg = "surface1"

    ["ui.highlight"]
    bg = "overlay1"

    ["ui.virtual.indent-guide"]
    fg = "surface1"

    ["ui.virtual.inlay-hint"]
    fg = "overlay1"

    ["ui.virtual.wrap"]
    fg = "overlay1"

    ["ui.virtual.ruler"]
    bg = "surface0"

    ["ui.gutter"]
    bg = "base"

    ["ui.gutter.selected"]
    bg = "surface0"

    # 语法高亮配色
    [keyword]
    fg = "mauve"

    [function]
    fg = "blue"

    [function.builtin]
    fg = "peach"

    [function.macro]
    fg = "mauve"

    [operator]
    fg = "sky"

    [variable]
    fg = "text"

    [variable.builtin]
    fg = "red"

    [variable.parameter]
    fg = "maroon"

    [variable.other.member]
    fg = "teal"

    [type]
    fg = "yellow"

    [type.builtin]
    fg = "yellow"

    [type.enum.variant]
    fg = "peach"

    [constructor]
    fg = "sapphire"

    [constant]
    fg = "peach"

    [constant.numeric]
    fg = "peach"

    [constant.builtin]
    fg = "peach"

    [constant.character.escape]
    fg = "pink"

    [string]
    fg = "green"

    [string.regexp]
    fg = "peach"

    [string.special]
    fg = "blue"

    [string.special.path]
    fg = "green"

    [string.special.url]
    fg = "rosewater"

    [string.special.symbol]
    fg = "red"

    [comment]
    fg = "overlay1"

    [attribute]
    fg = "yellow"

    [label]
    fg = "blue"

    [punctuation]
    fg = "overlay2"

    [punctuation.special]
    fg = "sky"

    [tag]
    fg = "mauve"

    [markup.heading]
    fg = "lavender"

    [markup.list]
    fg = "mauve"

    [markup.bold]
    fg = "peach"

    [markup.italic]
    fg = "yellow"

    [markup.link.url]
    fg = "rosewater"

    [markup.link.text]
    fg = "blue"

    [markup.quote]
    fg = "overlay1"

    [markup.raw]
    fg = "green"

    [diff]
    fg = "text"

    [diff.plus]
    fg = "green"

    [diff.minus]
    fg = "red"

    [diff.delta]
    fg = "blue"

    [diagnostic]
    fg = "overlay1"

    [diagnostic.hint]
    fg = "lavender"

    [diagnostic.info]
    fg = "blue"

    [diagnostic.warning]
    fg = "yellow"

    [diagnostic.error]
    fg = "red"
  '';
}
