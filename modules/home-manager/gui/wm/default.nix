# Niri 窗口管理器 — 用户级配置文件部署
# KDL 颜色通过 Stylix 统一管理
{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.mengw.gui.wm;
  guiCfg = config.mengw.gui;
  niriConfigPath = "${config.home.homeDirectory}/nixos-config/modules/home-manager/gui/wm/config";

  # Stylix 调色板；Stylix 禁用时回退到 Gruvbox Dark（与默认主题一致）
  colors = config.lib.stylix.colors.withHashtag or {
    base00 = "#1d2021"; # dark bg
    base01 = "#3c3836"; # dark gray
    base02 = "#504945"; # medium gray
    base03 = "#665c54"; # light gray
    base04 = "#bdae93"; # dark fg
    base05 = "#d5c4a1"; # foreground
    base06 = "#ebdbb2"; # light fg
    base07 = "#fbf1c7"; # brightest
    base08 = "#fb4934"; # red
    base09 = "#fe8019"; # orange
    base0A = "#fabd2f"; # yellow
    base0B = "#b8bb26"; # green
    base0C = "#8ec07c"; # aqua
    base0D = "#83a598"; # blue
    base0E = "#d3869b"; # purple
    base0F = "#d65d0e"; # brown
  };

  # 由 Stylix 调色板生成的 layout.kdl
  layoutKdl = pkgs.writeText "layout.kdl" ''
    // niri 窗口布局配置 — 颜色由 Stylix 统一管理
    // https://niri-wm.github.io/niri/Configuration%3A-Layout.html
    layout {
        gaps 8     // 窗口和屏幕边缘的间距
        background-color "transparent"  // 工作区透明
        center-focused-column "never"   // 无特殊居中效果
        always-center-single-column     // 工作区只包含一列，该列居中显示
        // 新窗口的默认列宽
        default-column-width { proportion 0.5; }

        // 焦点环，用于指示活动窗口
        focus-ring {
            on          // 开启焦点环
            width 3     // 焦点环宽度
            inactive-color "${colors.base0D}"
            // 活动窗口焦点环渐变色
            active-gradient from="${colors.base08}" to="${colors.base09}" angle=45
        }

        // 边框，用于指示活动窗口
        border {
            off
            width 4
            active-color "${colors.base0A}"
            inactive-color "${colors.base03}"
            urgent-color "${colors.base08}"
        }

        // 标签指示器
        tab-indicator {
            on
            place-within-column // 指示器绘制列内部
            gap 5 // 指示器与窗口边缘间距
            width 3 // 指示器宽度
            length total-proportion=1.0 // 指示器长度占列总高度比例
            position "right" // 指示器在列的右侧
            gaps-between-tabs 2 // 多个标签指示器并排时间距
            corner-radius 8 // 指示器圆角半径
            active-color "${colors.base0D}" // 活跃标签指示器颜色
            inactive-color "${colors.base04}" // 非活跃标签指示器颜色
            urgent-color "${colors.base08}" // 紧急标签指示器颜色
        }

        // 窗口插入提升
        insert-hint {
            on
            color "${colors.base09}80"
        }
    }
  '';

  # 由 Stylix 调色板生成的 overview.kdl
  overviewKdl = pkgs.writeText "overview.kdl" ''
    // 概览 — 颜色由 Stylix 统一管理
    overview {
        zoom 0.40
        backdrop-color "${colors.base03}"
    }

    // 带缩略图的 Super+Tab 窗口切换器
    recent-windows {
        debounce-ms 750
        open-delay-ms 150

        highlight {
            padding 30
            corner-radius 12
        }

        previews {
            max-height 480
            max-scale 0.2
        }

        binds {
            Mod+Tab         { next-window scope="workspace"; }
            Mod+Shift+Tab   { previous-window scope="workspace"; }
            Mod+grave       { next-window     filter="app-id"; }
            Mod+Shift+grave { previous-window filter="app-id"; }
        }
    }
  '';
in
{
  options.mengw.gui.wm.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Niri 窗口管理器用户级配置";
  };

  imports = [
    ./noctalia.nix
  ];

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    # Symlink 整个 Niri 配置目录到 git 仓库（保持可编辑性）
    xdg.configFile."niri".source = config.lib.file.mkOutOfStoreSymlink niriConfigPath;

    # 用 Stylix 生成的模板文件覆盖 layout.kdl 和 overview.kdl
    # home.activation 在 linkGeneration 之后运行，可以安全覆盖 symlink 文件
    home.activation.niriStylixColors = lib.mkAfter ''
      if [ -d "$HOME/.config/niri/visual" ]; then
        cp -f ${layoutKdl} "$HOME/.config/niri/visual/layout.kdl"
        cp -f ${overviewKdl} "$HOME/.config/niri/visual/overview.kdl"
      fi
    '';
  };
}
