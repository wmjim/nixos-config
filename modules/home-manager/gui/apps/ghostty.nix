# Ghostty 终端配置
#
# 亮/暗：一个 theme 选项写两态，ghostty 自己按「当前桌面主题」选（Linux 侧读的是 dconf 的
# org.gnome.desktop.interface color-scheme —— 正是 theme-apply 在切的那个键），所以新窗口
# 天然跟随，不需要翻文件或发信号。两个名字必须写全、两态都写（ghostty 文档：
# light:NAME,dark:NAME，只写一个会报错）；均取自 ghostty 自带的主题
# （`ghostty +list-themes` 里有 Catppuccin Frappe / Latte）。
# 其它取值（字体、内置着色器、quick terminal、shell 集成等）见各条注释。
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

        # 背景保持不透明（1.0）：半透明与模糊都交给 niri 的 window-rule，见
        # wm/config/visual/frosted-glass.kdl 那条规则的注释（含对比度算据）。
        #
        # 试过另一种做法并量过：ghostty 自己只压背景（background-opacity = 0.80）+
        # niri 侧 opacity 1.0。结果文字确实更清晰，但**玻璃基本看不出来** —— 让玻璃“显形”
        # 的其实是文字连同底色一起透到壁纸上（实测：暗区背后 0.8×#303446 = #2A2E3F，与纯色
        # #303446 几乎无差）；而且 niri 的透明度对**已经开着**的窗口即时生效，ghostty 自己的
        # 配置要重开才生效。故回到 niri 侧整体透明度。
        background-opacity = 1.0;
        # 内边距 x=8 y=6
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
        # 故这里不要 GTK 的完整标题栏，否则会多出一条标题栏。
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
