# Alacritty 终端配置
{ lib, config, ... }:
let
  cfg = config.mengw.gui.apps.alacritty;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.alacritty.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Alacritty 终端模拟器";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    programs.alacritty = {
      enable = true;
      # Catppuccin Frappe 主题
      theme = "catppuccin_frappe";
      settings = {
        general = {
          # 继承启动进程的工作目录
          working_directory = "None";
        };

        env = {
          TERM = "xterm-256color";
        };

        window = {
          # 不透明度：1.0 完全不透明
          opacity = 1.0;
          # 内边距
          padding = {
            x = 8;
            y = 6;
          };
          # 完整窗口装饰
          decorations = "Full";
        };

        font = {
          normal = {
            family = "Maple Mono Normal NL NF";
          };
          size = 12;
        };

        scrolling = {
          history = 10000;
        };

        cursor = {
          style = {
            # 块状光标
            shape = "Block";
            # 默认启用闪烁
            blinking = "On";
          };
        };

        mouse = {
          # 输入时隐藏鼠标指针
          hide_when_typing = true;
        };

        selection = {
          # 选中即复制到剪贴板
          save_to_clipboard = true;
        };
      };
    };
  };
}
