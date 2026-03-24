{ config, pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      # 字体配置
      font-family = "Maple Mono NF";
      font-size = 15;
      font-thicken = true;
      adjust-cell-height = 2;

      # 主题 - 使用内置 Dracula 主题
      theme = "Catppuccin Frappe";


      # 窗口
      # background-opacity = 0.9;
      background-blur-radius = 20;
      macos-titlebar-style = "transparent";
      window-padding-x = 10;
      window-padding-y = 8;
      window-save-state = "always";
      window-theme = "auto";

      # 光标
      cursor-style = "bar";
      cursor-style-blink = true;
      cursor-opacity = 0.8;

      # 鼠标
      mouse-hide-while-typing = true;
      copy-on-select = "clipboard";

      # 下拉终端（Quake 风格）
      quick-terminal-position = "top";
      quick-terminal-screen = "mouse";
      quick-terminal-autohide = true;
      quick-terminal-animation-duration = 0.15;

      # 安全
      clipboard-paste-protection = true;
      clipboard-paste-bracketed-safe = true;

      # 滚动
      # scrollback = 10000;

      # Shell
      shell-integration = "detect";
      # shell = "$SHELL";
      # Bell
      # bell = "none";
    };
  };
}
