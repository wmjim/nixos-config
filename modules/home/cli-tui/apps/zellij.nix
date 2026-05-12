# Zellij — 终端复用器（tmux 替代品）
# 使用场景：跨平台（NixOS / macOS / WSL）终端工作流
{ ... }: {
  # 启用 home-manager 的 Zellij 模块（安装二进制 + 管理配置文件）
  programs.zellij = { enable = true; };

  # 直接部署 KDL 格式配置文件到 ~/.config/zellij/config.kdl
  # 原因：home-manager 的 programs.zellij.settings 只支持已废弃的 YAML 格式，
  #       而 Zellij 官方推荐 KDL，故用 home.file 手动部署
  home.file.zellij = {
    target = ".config/zellij/config.kdl";
    text = ''
      // ── 界面精简 ──────────────────────────────────────────────
      // 隐藏状态栏中不常用的 UI 元素，只保留核心信息
      simplified_ui true

      // ── 默认布局 ──────────────────────────────────────────────
      // "compact" 布局在启动时自动创建一个带状态栏的单面板，
      // 比 "default" 布局更节省屏幕空间
      default_layout "compact"

      // ── 快捷键定义 ─────────────────────────────────────────────
      // clear-defaults=true：清除所有 Zellij 自带快捷键，
      // 仅保留下面定义的自定义键位，避免冲突
      keybinds clear-defaults=true {
        // ························································
        // Normal 模式 — 默认状态下的快捷键
        // ························································
        normal {
          // Ctrl+o 切换到 tmux 模式（模拟 tmux 的 prefix 概念）
          bind "Ctrl o" { SwitchToMode "tmux"; }
        }

        // ························································
        // tmux 模式 — 按 Ctrl+o 后进入，模拟 tmux 的 prefix 快捷键体系
        // 设计意图：彻底替换 tmux，保留已有肌肉记忆
        // ························································
        tmux {
          // 再按一次 Ctrl+o 回到 Normal 模式（toggle 行为）
          bind "Ctrl o" { SwitchToMode "Normal"; }
          // Esc 退出 tmux 模式（与 tmux 的 Escape 行为一致）
          bind "Esc" { SwitchToMode "Normal"; }

          // ── 快捷命令 ──────────────────────────────────────────
          // Ctrl+e → 在光标位置输入 "vi ." 并回车（快速打开当前目录的编辑器）
          bind "Ctrl e" { WriteChars "vi ."; Write 13; SwitchToMode "Normal"; }
          // Ctrl+r → 输入 "kubie ctx" 并回车（快速切换 Kubernetes 上下文）
          bind "Ctrl r" { WriteChars "kubie ctx"; Write 13; SwitchToMode "Normal"; }

          // ── 面板操作 ──────────────────────────────────────────
          // Ctrl+u 关闭当前焦点面板（等价 tmux 的 kill-pane）
          bind "Ctrl u" { CloseFocus; SwitchToMode "Normal"; }
          // z 切换当前面板全屏/还原（等价 tmux 的 zoom）
          bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
          // d 断开当前会话（等价 tmux 的 detach）
          bind "d" { Detach; }
          // s 同步/取消同步当前 Tab 下所有面板的输入（等价 tmux 的 synchronize-panes）
          bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }

          // ── 焦点移动（Vim 风格 hjkl）─────────────────────────
          bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
          bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
          bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
          bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }

          // ── 新建面板 ──────────────────────────────────────────
          // y 在下方新建面板（横向分割，等价 tmux 的 split-window -v）
          bind "y" { NewPane "Down"; SwitchToMode "Normal"; }
          // n 在右侧新建面板（纵向分割，等价 tmux 的 split-window -h）
          bind "n" { NewPane "Right"; SwitchToMode "Normal"; }

          // ── Tab 管理 ──────────────────────────────────────────
          // c 新建 Tab（等价 tmux 的 new-window）
          bind "c" { NewTab; SwitchToMode "Normal"; }
          // Ctrl+l 切换到下一个 Tab
          bind "Ctrl l" { GoToNextTab; SwitchToMode "Normal"; }
          // Ctrl+h 切换到上一个 Tab
          bind "Ctrl h" { GoToPreviousTab; SwitchToMode "Normal"; }
        }
      }

      // ── 主题设置 ──────────────────────────────────────────────
      // 当前使用 Catppuccin Mocha（暗色主题，与系统其余部分保持一致）
      theme "catppuccin-mocha"

      // ── 自定义主题色板 ────────────────────────────────────────
      // 颜色值支持 RGB 十进制整数 "R G B" 或十六进制 "#RRGGBB"
      // 注释中的名称对应 Catppuccin 调色板的标准色号
      themes {
        // 备用主题：Tokyo Night Dark（未启用，保留作为切换选项）
        tokyo-night-dark {
          fg 169 177 214      // 前景色 — 文本
          bg 26 27 38         // 背景色
          black 56 62 90      // 黑色（面板边框等）
          red 249 51 87       // 红色（错误/关闭）
          green 158 206 106   // 绿色（成功/运行中）
          yellow 224 175 104  // 黄色（警告）
          blue 122 162 247    // 蓝色（信息/链接）
          magenta 187 154 247 // 品红（高亮）
          cyan 42 195 222     // 青色（会话名等）
          white 192 202 245   // 白色（亮文本）
          orange 255 158 100  // 橙色（特殊标记，Zellij 特有扩展）
        }

        // 主用主题：Catppuccin Mocha（与 Ghostty、Starship、Helix 统一）
        catppuccin-mocha {
          bg "#585b70"        // Surface2 — 比 base 稍亮，区分面板
          fg "#cdd6f4"        // Text — 主文本色
          red "#f38ba8"       // Red — 错误/关闭
          green "#a6e3a1"     // Green — 成功/运行中
          blue "#89b4fa"      // Blue — 信息/链接
          yellow "#f9e2af"    // Yellow — 警告
          magenta "#f5c2e7"   // Pink — 高亮
          orange "#fab387"    // Peach — 特殊标记
          cyan "#89dceb"      // Sky — 会话名等
          black "#181825"     // Mantle — 最深色，面板边框
          white "#cdd6f4"     // Text — 亮文本（与 fg 同色）
        }
      }
    '';
  };
}