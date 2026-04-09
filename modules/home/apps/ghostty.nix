# Ghostty 终端配置
{ config, pkgs, ... }:

{
  # Ghostty 通过 home-manager 配置
  programs.ghostty = {
    enable = true;
    settings = {
      # 设置终端字体（支持 Nerd Font，适合图标）
      font-family = "Maple Mono NF";
      # 设置字体大小
      font-size = 15;
      # 启用字体加粗/加厚（提高可读性
      font-thicken = true;
      # 调整行高（1 表示轻微增加
      adjust-cell-height = 2;

      # 设置主题
      theme = "Ayu";

      # 窗口
      # 设置背景透明度（0~1）
      background-opacity = 0.90;
      # 背景模糊半径（macOS 特效）
      background-blur-radius = 30;
      # 标题栏样式（透明）
      macos-titlebar-style = "transparent";
      # 禁用窗口按步进缩放（更平滑）
      window-step-resize = false;
      # 窗口左右内边距
      window-padding-x = 10;
      # 窗口上下内边距
      window-padding-y = 8;
      # 保存窗口状态（大小/位置）
      window-save-state = "always";
      # 窗口主题自动切换（跟随系统）
      window-theme = "auto";

      # 光标样式（竖线）
      cursor-style = "bar";
      # 光标闪烁
      cursor-style-blink = true;
      # 光标透明度
      cursor-opacity = 0.8;

      # 输入时隐藏鼠标
      mouse-hide-while-typing = true;
      # 选中自动复制到剪贴板
      copy-on-select = "clipboard";

      # 下拉终端位置（顶部）
      quick-terminal-position = "top";
      # 在鼠标所在屏幕打开
      quick-terminal-screen = "mouse";
      # 自动隐藏
      quick-terminal-autohide = true;
      # 动画时长（秒）
      quick-terminal-animation-duration = 0.15;

      # 粘贴保护（防止误执行危险命令）
      clipboard-paste-protection = true;
      # 安全 bracketed paste 模式
      clipboard-paste-bracketed-safe = true;

      # 滚动缓冲区大小（25MB，大约可回滚很多历史）
      scrollback-limit = 25000000;

      # shell 集成
      shell-integration = "fish";

      #避免root识别问题
      term = "xterm-256color";

      # --- Keybindings ---
      keybind = [
        # Tabs
        # 新建标签页
        "cmd+t=new_tab"
        # 切换到左侧标签页
        "cmd+shift+left=previous_tab"
        # 切换到右侧标签页
        "cmd+shift+right=next_tab"
        # 关闭当前标签/窗口
        "cmd+w=close_surface"

        # Splits
        # 向右分屏
        "cmd+d=new_split:right"
        # 向下分屏
        "cmd+shift+d=new_split:down"
        # 切换到左侧分屏
        "cmd+alt+left=goto_split:left"
        # 切换到右侧分屏
        "cmd+alt+right=goto_split:right"
        # 切换到上方分屏
        "cmd+alt+up=goto_split:top"
        # 切换到下方分屏
        "cmd+alt+down=goto_split:bottom"

        # Font size
        # 增大字体
        "cmd+plus=increase_font_size:1"
        # 减小字体
        "cmd+minus=decrease_font_size:1"
        # 重置字体大小
        "cmd+zero=reset_font_size"

        # 全局快捷键：打开/关闭下拉终端
        "global:ctrl+grave_accent=toggle_quick_terminal"

        # Splits management
        # 平均分配分屏大小
        "cmd+shift+e=equalize_splits"
        # 最大化/还原当前分屏
        "cmd+shift+f=toggle_split_zoom"

        # 重新加载配置文件
        "cmd+shift+comma=reload_config"
      ];
    };
  };
}
