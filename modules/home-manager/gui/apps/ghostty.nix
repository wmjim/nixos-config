# Ghostty 终端配置
# 颜色主题由 Stylix 统一管理（自动生成 stylix 主题）
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.apps.ghostty;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.ghostty.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Ghostty 终端模拟器";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    programs.ghostty = {
      enable = true;
      settings = {
        # 使用主题, 默认目录：~/.config/ghostty/themes
        theme = "stylix";
        # 字体设置
        font-family = [ "Maple Mono Normal NL NF" "LXGW WenKai Mono" ];
        font-size = 12;
        # 行间距：+2像素
        adjust-cell-height = 2;
        # 背景不透明度：1.0, 完全不透明
        background-opacity = 1.0;
        # 水平窗口内边距：8
        window-padding-x = 8;
        # 垂直窗口内边距：6
        window-padding-y = 6;
        # 窗口主题：auto, 根据配置的终端背景确定主题
        window-theme = "auto";
        # === 光标 ===
        # 光标样式：block, 块状
        cursor-style = "block";
        # 光标闪烁：开启
        cursor-style-blink = true;
        # 光标的不透明度：0.8
        cursor-opacity = 0.8;
        # 自定义着色器
        custom-shader = [
          "~/.config/ghostty/shader/cursor_smear_rainbow.glsl"
          "~/.config/ghostty/shader/party_sparks.glsl"
        ];
        # 运行动画循环以帮助着色器实现动画效果
        custom-shader-animation = "always";
        
        

        # === 下拉终端 ===
        # 下拉终端位置：top, 屏幕顶部
        quick-terminal-position = "top";
        # 下拉终端显示位置：mouse, 鼠标当前悬停所在屏幕
        quick-terminal-screen = "mouse";
        # 当焦点切换其它窗口时自动隐藏快速终端
        quick-terminal-autohide = true;
        # 下拉终端进入/退出动画时间
        quick-terminal-animation-duration = 0.15;

        # === 粘贴 ===
        # 粘贴不安全文本需要确认
        clipboard-paste-protection = true;
        # 带括号内容视为安全
        clipboard-paste-bracketed-safe = true;
        # 选择即复制
        copy-on-select = "clipboard";
        # 允许在终端运行的程序读写系统剪贴板
        clipboard-read = "allow";
        clipboard-write = "allow";

        # 输入时隐藏鼠标
        mouse-hide-while-typing = true;

        # === fish ===
        # shell 集成自动注入：fish
        shell-integration = "fish";
        # 启用 shell 集成功能
        # cursor: 将光标设置为提示符处竖线
        # sudo: 设置 sudo 包装器
        # title: 通过 shell 集成设置窗口标题
        shell-integration-features = [
          "cursor"
          "sudo"
          "title"
        ];

        # 回滚缓冲区字节大小
        scrollback-limit = 25000000;
        # 启动命令后要切换的目录：inherit, 启动进程的工作目录
        working-directory = "inherit";
        # 启用窗口状态的保存和恢复：always, 每次退出都会保存窗口状态
        window-save-state = "always";


        # 配置窗口装饰
        # none: 所有窗口装饰都将被禁用
        # auto: 检测操作系统和桌面环境偏好，自动决定客户端装饰
        # client: 客户端装饰
        # server: 服务端装饰
        window-decoration = "auto";
        # 完整 GTK 标题栏
        gtk-titlebar = true;
        # 环境变量兼容性
        term = "xterm-ghostty";
        # 修饰键 super / ctrl / shift / alt
        keybind = [
        ];
      };
    };

    xdg.configFile = {
      "ghostty/shader/cursor_smear_rainbow.glsl".source = ./ghostty-shader/cursor_smear_rainbow.glsl;
      "ghostty/shader/party_sparks.glsl".source = ./ghostty-shader/party_sparks.glsl;
    };
  };
}
