# Ghostty 终端配置
{ config, pkgs, ... }:

{
  # Ghostty 通过 home-manager 配置
  programs.ghostty = {
    enable = true;
    settings = {
      # --- 主题 ---
      theme = "Catppuccin Mocha";


      # --- 字体 ---
      font-family = [ "Maple Mono Normal NL NF" "LXGW WenKai Mono" ];
      font-size = 12;
      font-thicken = true; # 加粗
      adjust-cell-height = 2; # 行高

      # --- 窗口外观 ---
      background-opacity = 1.0; # 背景透明度
      background-blur-radius = 20; # 背景模糊半径
      # 标题栏样式（透明）
      # macos-titlebar-style = "transparent";
      window-padding-x = 10; # 左右内边距
      window-padding-y = 8; # 上下内边距
      window-step-resize = false; # 禁用窗口按步进缩放（更平滑）
      window-save-state = "always"; # 窗口状态记忆（重启不丢布局）
      window-theme = "auto"; # 窗口主题自动切换（跟随系统）
      # gtk-titlebar = false;         # 保留边框，禁用标题栏

      # --- 光标 ---
      cursor-style = "block"; # 样式（block — 游标着色器在 bar/underline 下有 bug，见 ghostty#7893）
      cursor-style-blink = true; # 闪烁
      cursor-opacity = 0.8; # 光标透明度

      # --- 光标着色器特效 ---
      # https://github.com/KroneCorylus/ghostty-shader-playground
      # 游标跳跃拖尾（Neovide 风格） + 模式切换涟漪
      custom-shader = [
        "~/.config/ghostty/shader/cursor_smear_rainbow.glsl"
        "~/.config/ghostty/shader/party_sparks.glsl"
      ];
      # 让着色器持续渲染（否则拖尾动画会冻结）
      custom-shader-animation = "always";

      # --- 鼠标 ---
      # 输入时自动隐藏鼠标
      mouse-hide-while-typing = true;
      # 选中自动复制到剪贴板
      copy-on-select = "clipboard";

      # --- 快速终端 ---
      quick-terminal-position = "top"; # 下拉终端位置（顶部）
      quick-terminal-screen = "mouse"; # 在鼠标所在屏幕打开
      quick-terminal-autohide = true; # 自动隐藏
      quick-terminal-animation-duration = 0.15; # 动画时长（秒）

      # --- 安全 ---
      # 粘贴保护（防止误执行危险命令）
      clipboard-paste-protection = true;
      # 安全 bracketed paste 模式
      clipboard-paste-bracketed-safe = true;

      # --- shell 集成 ---
      shell-integration = "fish";
      # 禁止 shell integration 修改光标形状（否则提示符处会变 bar，导致光标着色器失效）
      shell-integration-features = "no-cursor";

      # 滚动缓冲区大小（25MB，大约可回滚很多历史）
      scrollback-limit = 25000000;
      # 避免root识别问题
      term = "xterm-256color";

      # --- 快捷键 ---
      # ctrl-control，alt-opt，super-cmd
      keybind = [
        # 智能复制：有选中文本时复制，无选中时发送 SIGINT
        "performable:ctrl+c=copy_to_clipboard"
        # 粘贴
        "ctrl+v=paste_from_clipboard"

        # 新建标签页
        "cmd+t=new_tab"
        # 切换到左侧标签页
        # "shift+left=previous_tab"
        # 切换到右侧标签页
        # "shift+right=next_tab"
        # 关闭当前标签/窗口
        "cmd+w=close_surface"

        # Splits
        # 向右分屏
        # "cmd+d=new_split:right"
        # 向下分屏
        # "cmd+shift+d=new_split:down"
        # 平均分配分屏大小
        # "cmd+shift+e=equalize_splits"
        # 最大化/还原当前分屏
        # "cmd+shift+enter=toggle_split_zoom"
        # 切换到左侧分屏
        # "alt+left=goto_split:left"
        # 切换到右侧分屏
        # "alt+right=goto_split:right"
        # 切换到上方分屏
        # "alt+up=goto_split:top"
        # 切换到下方分屏
        # "alt+down=goto_split:bottom"

        # 增大字体
        "control+plus=increase_font_size:1"
        # 减小字体
        "control+minus=decrease_font_size:1"
        # 重置字体大小
        "control+zero=reset_font_size"

        # 全局快速呼出
        # "global:cmd+t=toggle_quick_terminal"
        # 下拉终端位置：top（top | center | bottom）
        # "quick-terminal-position=top"

        # 重新加载配置文件
        "cmd+shift+comma=reload_config"
      ];
    };
  };

  # 将 shader 文件部署到 ~/.config/ghostty/shader/
  xdg.configFile = {
    "ghostty/shader/cursor_smear_rainbow.glsl".source = ./shader/cursor_smear_rainbow.glsl;
    "ghostty/shader/party_sparks.glsl".source = ./shader/party_sparks.glsl;
  };
}
