# Foot 终端配置（Wayland 原生，Niri / GNOME 会话共用；不适用于 macOS）
# 由 Alacritty 迁移而来，各项参数逐条对齐，保证切换前后观感一致
{ lib, config, ... }:
let
  cfg = config.mengw.gui.apps.foot;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.foot.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Foot 终端模拟器";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    programs.foot = {
      enable = true;

      settings = {
        main = {
          # 远端主机没装 foot terminfo 时会报 "unknown terminal type"
          term = "foot";

          # 字号 = 12pt@96dpi × 输出缩放
          # 默认值 auto 会改用显示器真实 DPI，4K 屏上字体会明显变大。
          dpi-aware = "no";
          font = "Maple Mono Normal NL NF:size=12";

          # padding x=8 y=6（foot 的 XxY = 左右 x 上下）
          pad = "8x6";

          # 选中即复制，同时写入 primary 与 clipboard 两个选区
          selection-target = "both";
        };

        scrollback.lines = "10000";

        cursor = {
          style = "block";
          blink = "yes";
        };

        mouse.hide-when-typing = "yes";

        key-bindings = {
          # 与 Super+C/X/V 的三键统一：keyd 把它们重映射成 Ctrl+C/X/V，唯独焦点
          # 在终端时由 keyd-app-niri 换成 Ctrl+Shift+C/X/V（见 wm/default.nix）。
          # 这里显式钉住接收端键位，避免 foot 上游默认值变动后失联。foot 自身不设
          # Mod4 系绑定——Super 组合已被合成器截获，且 GNOME 下 Super+V 被 Shell
          # 占用，无法保证一致。
          clipboard-copy = "Control+Shift+c";
          clipboard-paste = "Control+Shift+v";

          # foot 默认无全屏快捷键
          fullscreen = "F11";
        };

        # catppuccin_frappe 主题：
        # 窗口半透明不在终端里设（alpha 保持 1.0），统一交给 niri 的 window-rule，
        # 见 wm/config/visual/frosted-glass.kdl。
        "colors-dark" = {
          background = "303446"; # base
          foreground = "C6D0F5"; # text

          # 两值分别为文字色与光标色（对应 alacritty 的 cursor.text / cursor.cursor）
          cursor = "303446 F2D5CF"; # base / rosewater

          selection-foreground = "303446"; # base
          selection-background = "F2D5CF"; # rosewater

          regular0 = "51576D"; # surface1
          regular1 = "E78284"; # red
          regular2 = "A6D189"; # green
          regular3 = "E5C890"; # yellow
          regular4 = "8CAAEE"; # blue
          regular5 = "F4B8E4"; # pink
          regular6 = "81C8BE"; # teal
          regular7 = "B5BFE2"; # subtext1

          bright0 = "626880"; # surface2
          bright1 = "E78284"; # red
          bright2 = "A6D189"; # green
          bright3 = "E5C890"; # yellow
          bright4 = "8CAAEE"; # blue
          bright5 = "F4B8E4"; # pink
          bright6 = "81C8BE"; # teal
          bright7 = "A5ADCE"; # subtext0

          # 上游主题把 dim 系列写得与常规色完全相同（即"不变暗"），照抄才能
          # 复现 alacritty 下的实际观感；不设则 foot 会按混合黑色自行变暗
          dim0 = "51576D"; # surface1
          dim1 = "E78284"; # red
          dim2 = "A6D189"; # green
          dim3 = "E5C890"; # yellow
          dim4 = "8CAAEE"; # blue
          dim5 = "F4B8E4"; # pink
          dim6 = "81C8BE"; # teal
          dim7 = "B5BFE2"; # subtext1

          # 搜索框：对应 alacritty 的 search.matches（foot 不区分 focused_match）
          search-box-match = "303446 A5ADCE"; # base / subtext0
          # alacritty 无"无匹配"配色，借用 palette 里的红色作为提示
          search-box-no-match = "303446 E78284"; # base / red

          # 链接下划线与跳转标签：对应 alacritty 的 hints.start（base on yellow）
          urls = "E5C890"; # yellow
          jump-labels = "303446 E5C890"; # base / yellow
        };
      };
    };
  };
}
