{ config, pkgs, ... }:

{
  programs.kitty = {
    enable = true;

    # Kitty 配置
    settings = {
      # 字体配置
      font_family = "Maple Mono NF CN";
      bold_font = "Maple Mono NF CN Bold";
      italic_font = "Maple Mono NF CN Italic";
      bold_italic_font = "Maple Mono NF CN Bold Italic";
      font_size = "12.0";

      # 窗口配置
      remember_window_size = "yes";
      window_padding_width = "4";          # 窗口内边距（减小到 4）
      window_margin_width = "0";           # 窗口外边距
      window_border_width = "0.5px";       # 边框宽度
      window_border_conceal = "no";        # 显示边框以增强磨砂效果
      window_gap_width = "4";              # 分割窗口之间的间隙（新增，减小间隙）
      single_window_margin_width = "-1";   # 单个窗口时无边距

      # 标签栏
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_bar_min_tabs = "2";
      tab_powerline_style = "slanted";
      tab_separator = " ┇";

      # 颜色主题（Catppuccin Mocha）
      # Catppuccin Mocha - 深色主题
      foreground = "#CDD6F4";
      background = "#1E1E2E";

      # 磨砂玻璃效果
      background_opacity = "0.85";
      background_blur = "32";  # 模糊半径（像素）
      dynamic_background_opacity = "yes";

      selection_foreground = "#1E1E2E";
      selection_background = "#F5E0DC";

      # 光标颜色
      cursor = "#F5E0DC";
      cursor_text_color = "#1E1E2E";

      # URL 颜色
      url_color = "#89B4FA";

      # 终端颜色（Catppuccin Mocha）
      color0 = "#45475A";   # black
      color1 = "#F38BA8";   # red
      color2 = "#A6E3A1";   # green
      color3 = "#F9E2AF";   # yellow
      color4 = "#89B4FA";   # blue
      color5 = "#F5C2E7";   # magenta
      color6 = "#94E2D5";   # cyan
      color7 = "#BAC2DE";   # white
      color8 = "#585B70";   # bright black
      color9 = "#F38BA8";   # bright red
      color10 = "#A6E3A1";  # bright green
      color11 = "#F9E2AF";  # bright yellow
      color12 = "#89B4FA";  # bright blue
      color13 = "#F5C2E7";  # bright magenta
      color14 = "#94E2D5";  # bright cyan
      color15 = "#A6ADC8";  # bright white

      # 滚动条
      scrollback_lines = "10000";
      scrollback_pager = "less --chop-long-lines --RAW-CONTROL-CHARS +INPUT_LINE_NUMBER";

      # 鼠标
      mouse_hide_wait = "3.0";
      copy_on_select = "clipboard";

      # 性能
      repaint_delay = "10";
      input_delay = "3";
      sync_to_monitor = "yes";

      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";

      # 键盘快捷键
      kitty_mod = "ctrl+shift";

      # 调整字体大小
      increase_font_size = "ctrl+shift+equal";
      decrease_font_size = "ctrl+shift+minus";
      reset_font_size = "ctrl+shift+backspace";

      # 克隆 shell
      clone_shell = "ctrl+shift+semicolon";

      # 窗口操作
      close_window = "ctrl+shift+q";  # 覆盖默认的 ctrl+shift+escape
      next_window = "ctrl+shift+right";
      previous_window = "ctrl+shift+left";
      move_window_forward = "ctrl+shift+f";
      move_window_backward = "ctrl+shift+b";
      move_window_to_top = "ctrl+shift+home";
      move_window_to_bottom = "ctrl+shift+end";

      # 标签操作
      next_tab = "ctrl+shift+right";
      previous_tab = "ctrl+shift+left";
      new_tab = "ctrl+shift+t";
      close_tab = "ctrl+shift+w";
      move_tab_forward = "ctrl+shift+f";
      move_tab_backward = "ctrl+shift+b";

      # 布局
      next_layout = "ctrl+shift+l";

      # Shell 集成
      shell_integration = "enabled";

      # 远程控制
      allow_remote_control = "yes";
      listen_on = "unix:/tmp/kitty";

      # 环境
      term = "xterm-256color";
    };

    # Kitty 扩展（可选）
    extraConfig = ''
      # 自定义快捷键：使用 fish 作为 shell
      map ctrl+shift+enter new_window

      # 清除屏幕
      map ctrl+shift+k send_text all \x0c

      # 粘贴
      map ctrl+shift+v paste_from_clipboard
      map ctrl+shift+s paste_from_selection

      # 复制
      map ctrl+shift+c copy_to_clipboard

      # 磨砂玻璃效果增强
      # 确保窗口合成器支持背景模糊
      # 对于 Wayland: 需要 Wayland 合成器支持（如 sway, hyprland）
      # 对于 X11: 需要 picom 或类似的合成器
    '';
  };

  # 安装字体
  fonts.fontconfig.enable = true;
}
