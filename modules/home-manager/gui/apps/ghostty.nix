# Ghostty 终端配置
#
# 这份是 1b04c1c（终端从 Ghostty 换成 Alacritty）之前那份的恢复，并接上亮/暗切换。
# 与 foot 时期的差异只有配色机制：
#   - foot 用 [colors-dark]/[colors-light] 两段 + SIGUSR1/SIGUSR2 热切换，
#     且新实例永远以 colors-dark 起（亮色下新终端仍是深色，是它没有「初始主题」选项）；
#   - ghostty 一个 theme 选项就能写「亮:主题,暗:主题」两条，由它自己按**当前桌面主题**
#     选（Linux 侧读到的是 dconf 的 org.gnome.desktop.interface color-scheme，正是
#     theme-apply 在切的那个键），所以新窗口天然跟随，不需要我们再翻文件或发信号。
# 两个名字必须写全、两态都写（ghostty 文档：light:NAME,dark:NAME；只写一个会报错），
# 均为 ghostty 自带主题 —— `ghostty +list-themes` 里有 Catppuccin Frappe / Latte。
{ lib, config, ... }:
let
  cfg = config.mengw.gui.apps.ghostty;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.ghostty.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Ghostty 终端模拟器";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    programs.ghostty = {
      enable = true;
      settings = {
        # 亮/暗两套主题由 ghostty 自己按桌面主题选，见文件头说明
        theme = "light:Catppuccin Latte,dark:Catppuccin Frappe";

        # === 字体与度量 ===
        font-family = [
          "Maple Mono Normal NL NF"
          "LXGW WenKai Mono"
        ];
        font-size = 12;
        # 行间距：+2 像素
        adjust-cell-height = 2;

        # 背景保持不透明（1.0）：窗口的半透明与模糊统一交给 niri 的 window-rule，
        # 见 wm/config/visual/frosted-glass.kdl —— 与 foot 时期同一约定。
        background-opacity = 1.0;
        # 内边距 x=8 y=6（与 foot 时期的 8x6 一致）
        window-padding-x = 8;
        window-padding-y = 6;

        # === 光标 ===
        cursor-style = "block";
        cursor-style-blink = true;
        cursor-opacity = 0.8;
        # 自定义着色器（光标拖尾彩虹 + 粒子），文件在下方 xdg.configFile 里部署
        custom-shader = [
          "~/.config/ghostty/shader/cursor_smear_rainbow.glsl"
          "~/.config/ghostty/shader/party_sparks.glsl"
        ];
        # 让着色器能跑动画循环（否则只在重绘时步进）
        custom-shader-animation = "always";

        # === 下拉终端（quick terminal）===
        quick-terminal-position = "top";
        quick-terminal-screen = "mouse";
        quick-terminal-autohide = true;
        quick-terminal-animation-duration = 0.15;

        # === 剪贴板 ===
        clipboard-paste-protection = true;
        clipboard-paste-bracketed-safe = true;
        copy-on-select = "clipboard";
        clipboard-read = "allow";
        clipboard-write = "allow";

        # 输入时隐藏鼠标
        mouse-hide-while-typing = true;

        # === fish 集成 ===
        shell-integration = "fish";
        shell-integration-features = [
          "cursor"
          "sudo"
          "title"
        ];

        # === 其它 ===
        scrollback-limit = 25000000;
        working-directory = "inherit";
        window-save-state = "always";
        # 窗口装饰交给 niri：本仓库走 prefer-no-csd + 自绘圆角/阴影（见 docs/themes.md），
        # 故这里不要 GTK 的完整标题栏，否则会和 foot 时期一样多出一条标题栏。
        window-decoration = "auto";
        gtk-titlebar = false;
        term = "xterm-ghostty";
      };
    };

    xdg.configFile = {
      "ghostty/shader/cursor_smear_rainbow.glsl".source = ./ghostty-shader/cursor_smear_rainbow.glsl;
      "ghostty/shader/party_sparks.glsl".source = ./ghostty-shader/party_sparks.glsl;
    };
  };
}
