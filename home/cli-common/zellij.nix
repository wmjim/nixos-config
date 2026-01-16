{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    zellij  # 现代化的终端复用器（类似 tmux）
  ];

  # Zellij 配置文件
  # Zellij 是一个用 Rust 编写的终端复用器，提供了比 tmux 更现代的 UI 和更好的默认配置
  xdg.configFile."zellij/config.kdl".text = ''
    // ============================================
    // Zellij 终端复用器配置文件
    // ============================================

    // ============================================
    // 主题颜色定义 - Catppuccin Frappe 配色方案
    // ============================================
    theme "catppuccin" {
        bg "#303446"          // 背景色 (base)
        fg "#c6d0f5"          // 前景色/文本色 (text)
        red "#e78284"         // 红色 - 用于错误信息
        green "#a6d189"       // 绿色 - 用于成功信息
        blue "#8caaee"        // 蓝色 - 用于信息提示
        yellow "#e5c890"      // 黄色 - 用于警告信息
        magenta "#ca9ee6"     // 品红色/紫色 (mauve)
        orange "#ef9f76"      // 橙色 (peach)
        cyan "#81c8be"        // 青色 (teal)
        black "#292c3c"       // 黑色 (mantle)
        white "#b5bfe2"       // 白色 (subtext1)
    }

    // ============================================
    // UI 配置
    // ============================================
    simplified_ui true           // 使用简化的 UI 界面
    pane_frames false            // 默认隐藏面板边框
    session_serialization true   // 启用会话序列化（可恢复会话）

    // ============================================
    // Shell 配置
    // ============================================
    default_shell "fish"         // 默认使用 fish shell

    // ============================================
    // 鼠标支持
    // ============================================
    mouse_mode true              // 启用鼠标模式（可以用鼠标切换面板、调整大小等）

    // ============================================
    // 环境变量配置
    // ============================================
    env {
        EDITOR "hx"              // 默认编辑器设置为 Helix
        VISUAL "hx"              // 图形编辑器设置为 Helix
    }

    // ============================================
    // UI 面板配置
    // ============================================
    ui {
        pane_frames {
            rounded_corners true       // 面板边框使用圆角
            color_theme "catppuccin"  // 使用 Catppuccin 主题
        }
    }

    // ============================================
    // 键绑定配置
    // ============================================
    // 快捷键设计理念：
    // - 类似 tmux 的操作习惯，但更现代化
    // - Vim 风格的 hjkl 键位移动
    // - Alt 键用于面板切换，Ctrl 键用于主要操作
    keybinds {
        shared {
            // ----------------------------------------
            // 会话管理
            // ----------------------------------------
            bind "Ctrl p" {            // Ctrl+p - 分离会话（detach）
                Detach
            }

            bind "Ctrl g" {            // Ctrl+g - 锁定会话
                SwitchToMode "Locked"
            }

            // ----------------------------------------
            // 主要操作
            // ----------------------------------------
            bind "Ctrl q" {            // Ctrl+q - 退出 Zellij
                Quit
            }
            bind "Ctrl a" {            // Ctrl+a - 新建标签页
                NewTab
            }
            bind "Ctrl n" {            // Ctrl+n - 下一个标签页
                GoToNextTab
            }
            bind "Ctrl b" {            // Ctrl+b - 上一个标签页
                GoToPreviousTab
            }
            bind "Ctrl w" {            // Ctrl+w - 关闭当前标签页
                CloseTab
            }

            // ----------------------------------------
            // 面板操作（Pane Operations）
            // ----------------------------------------
            bind "Ctrl Shift \\" {     // Ctrl+Shift+\ - 垂直分割面板（右侧新建）
                NewPane "Right"
            }
            bind "Ctrl -" {            // Ctrl+- - 水平分割面板（下方新建）
                NewPane "Down"
            }
            bind "Ctrl o" {            // Ctrl+o - 切换到下一个面板
                FocusNextPane
            }
            bind "Ctrl e" {            // Ctrl+e - 切换到上一个面板
                FocusPreviousPane
            }
            bind "Ctrl x" {            // Ctrl+x - 关闭当前面板
                CloseFocus
            }

            // ----------------------------------------
            // 调整面板大小（Vim 风格 hjkl）
            // ----------------------------------------
            bind "Ctrl h" {            // Ctrl+h - 向左调整面板边界
                Resize "Increase Left"
            }
            bind "Ctrl l" {            // Ctrl+l - 向右调整面板边界
                Resize "Increase Right"
            }
            bind "Ctrl k" {            // Ctrl+k - 向上调整面板边界
                Resize "Increase Up"
            }
            bind "Ctrl j" {            // Ctrl+j - 向下调整面板边界
                Resize "Increase Down"
            }

            // ----------------------------------------
            // 使用方向键调整面板大小（Alt 修饰）
            // ----------------------------------------
            bind "Alt Left" {          // Alt+Left - 向左缩小面板
                Resize "Decrease Left"
            }
            bind "Alt Right" {         // Alt+Right - 向右缩小面板
                Resize "Decrease Right"
            }
            bind "Alt Up" {            // Alt+Up - 向上缩小面板
                Resize "Decrease Up"
            }
            bind "Alt Down" {          // Alt+Down - 向下缩小面板
                Resize "Decrease Down"
            }

            // ----------------------------------------
            // 切换面板焦点（Vim 风格 hjkl）
            // ----------------------------------------
            bind "Alt h" {             // Alt+h - 移动焦点到左侧面板
                MoveFocusOrTab "Left"
            }
            bind "Alt l" {             // Alt+l - 移动焦点到右侧面板
                MoveFocusOrTab "Right"
            }
            bind "Alt k" {             // Alt+k - 移动焦点到上方面板
                MoveFocusOrTab "Up"
            }
            bind "Alt j" {             // Alt+j - 移动焦点到下方面板
                MoveFocusOrTab "Down"
            }

            // ----------------------------------------
            // 滚动和显示模式
            // ----------------------------------------
            bind "Ctrl f" {            // Ctrl+f - 切换面板边框显示
                TogglePaneFrames
            }
            bind "Ctrl z" {            // Ctrl+z - 滚动到底部
                ScrollToBottom
            }

            // ----------------------------------------
            // 搜索模式
            // ----------------------------------------
            bind "Ctrl s" {            // Ctrl+s - 进入搜索模式
                SwitchToMode "Search"
            }
            bind "Ctrl Shift s" {      // Ctrl+Shift+s - 进入搜索模式
                SwitchToMode "Search"
            }

            // ----------------------------------------
            // 复制和滚动模式
            // ----------------------------------------
            bind "Ctrl [" {            // Ctrl+[ - 进入滚动模式（类似 Vim 的 normal 模式）
                SwitchToMode "Scroll"
            }
            bind "Ctrl Shift f" {      // Ctrl+Shift+f - 进入搜索模式
                SwitchToMode "Search"
            }

            // ----------------------------------------
            // 数字键快速切换标签页
            // ----------------------------------------
            bind "Alt 1" {
                GoToTab 1
            }                                // Alt+数字 - 快速跳转到对应标签页
            bind "Alt 2" {
                GoToTab 2
            }
            bind "Alt 3" {
                GoToTab 3
            }
            bind "Alt 4" {
                GoToTab 4
            }
            bind "Alt 5" {
                GoToTab 5
            }
            bind "Alt 6" {
                GoToTab 6
            }
            bind "Alt 7" {
                GoToTab 7
            }
            bind "Alt 8" {
                GoToTab 8
            }
            bind "Alt 9" {
                GoToTab 9
            }

            // ----------------------------------------
            // 其他布局操作
            // ----------------------------------------
            bind "Ctrl t" {            // Ctrl+t - 切换标签页可见性
                ToggleTab
            }
        }

        // ============================================
        // 滚动模式键绑定（Scroll Mode）
        // ============================================
        // 在此模式下可以浏览终端历史记录
        scroll {
            bind "Ctrl c" {            // Ctrl+c - 退出滚动模式
                SwitchToMode "Normal"
            }
            bind "Esc" {               // Esc - 退出滚动模式
                SwitchToMode "Normal"
            }

            // Vim 风格的移动
            bind "h" {                 // h - 向左移动（或切换到左侧标签页）
                MoveFocusOrTab "Left"
            }
            bind "j" {                 // j - 向下移动
                MoveFocus "Down"
            }
            bind "k" {                 // k - 向上移动
                MoveFocus "Up"
            }
            bind "l" {                 // l - 向右移动（或切换到右侧标签页）
                MoveFocusOrTab "Right"
            }

            // 上下滚动
            bind "Down" {              // Down arrow - 向下滚动
                ScrollDown
            }
            bind "Up" {                // Up arrow - 向上滚动
                ScrollUp
            }
        }

        // ============================================
        // 搜索模式键绑定（Search Mode）
        // ============================================
        search {
            bind "Ctrl c" {            // Ctrl+c - 取消搜索并退出
                SwitchToMode "Normal"
            }
            bind "Esc" {               // Esc - 取消搜索并退出
                SwitchToMode "Normal"
            }
            bind "c" {                 // c - 切换大小写敏感
                SearchToggleOption "CaseSensitivity"
            }
            bind "w" {                 // w - 切换自动换行搜索
                SearchToggleOption "Wrap"
            }
            bind "n" {                 // n - 切换全词匹配
                SearchToggleOption "WholeWord"
            }
        }

        // ============================================
        // 会话模式键绑定（Session Mode）
        // ============================================
        session {
            bind "Ctrl d" {            // Ctrl+d - 分离当前会话
                Detach
            }
        }
    }

    // ============================================
    // 布局模板定义
    // ============================================
    layout_templates {
        default {
            // 默认布局：单个全屏面板
            pane size=1 borderless=true
        }

        split_vertical {
            // 垂直分割布局：左右两个面板
            pane size=2 borderless=true {
                pane                    // 左侧面板
                pane                    // 右侧面板
            }
        }

        split_horizontal {
            // 水平分割布局：上下两个面板
            pane size=2 borderless=true {
                pane split="horizontal"  // 上方面板
                pane split="horizontal"  // 下方面板
            }
        }

        three_panes {
            // 三面板布局：一个主面板 + 两个子面板（开发常用）
            pane size=1 borderless=true {
                pane                    // 主面板（左侧大面板）
                pane size=2 split="horizontal"  // 右侧两个面板（上下分割）
            }
        }
    }

    // ============================================
    // 插件配置
    // ============================================
    plugins {
        tab-bar {
            color_theme "catppuccin"   // 标签栏使用 Catppuccin 主题
            rounded_corners true       // 使用圆角
        }

        status-bar {
            color_theme "catppuccin"   // 状态栏使用 Catppuccin 主题
            rounded_corners true       // 使用圆角
            height 1                   // 状态栏高度为 1 行
        }
    }
  '';
}
