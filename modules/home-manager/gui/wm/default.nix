# Niri 窗口管理器 — 用户级配置文件部署
{ lib, config, osConfig, pkgs, inputs, ... }:
let
  cfg = config.mengw.gui.wm;
  guiCfg = config.mengw.gui;
  niriConfigPath = "${config.home.homeDirectory}/Projects/nixos-config/modules/home-manager/gui/wm/config";

  # Gruvbox Dark 调色板
  colors = {
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

  # 生成的 layout.kdl
  layoutKdl = ''
    // niri 窗口布局配置
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

  # 生成的 overview.kdl
  overviewKdl = ''
    // 概览
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

  # 生成的 outputs.kdl（按主机区分）
  # niri 的 output 段按物理输出名匹配：把两台主机的定义混在一个文件里，
  # 未连接的输出条目会静默失效；且两处 focus-at-startup 在双屏场景下
  # 聚焦行为不确定。故按主机生成，每份配置只含一个 focus-at-startup。
  laptopOutputs = ''
    // 显示器设置（笔记本内屏）
    output "eDP-1" {
        mode "1920x1080@59.977"
        scale 1.25
        position x=0 y=0
        focus-at-startup
    }
  '';

  desktopOutputs = ''
    // 显示器设置（台式机 4K 屏）
    output "DP-2" {
        // 设置屏幕分辨率和刷新率
        mode "3840x2160@150.000"
        // 界面缩放为 150%
        scale 1.50
        // 设置屏幕位置
        position x=0 y=0
        // niri 启动时默认聚焦输出
        focus-at-startup
    }
  '';

  outputsKdl =
    let host = osConfig.networking.hostName; in
    if host == "laptop" then laptopOutputs
    else if host == "desktop" then desktopOutputs
    else throw "mengw.gui.wm: 未定义主机 ${host} 的 niri 显示器配置";

  # Ctrl+Alt+Del 关闭全部窗口
  # niri 只有作用于焦点窗口的 close-window，没有"关闭全部"动作：这里先快照
  # 当前所有窗口 id，再逐个 focus-window + close-window。逐个关闭而非 kill
  # 进程，是为了让应用走自己的关闭流程（弹"未保存"确认、落盘配置等）。
  # 只遍历一次快照：遇到卡在确认对话框关不掉的窗口就停下，不会死循环。
  niriCloseAll = pkgs.writeShellScriptBin "niri-close-all" ''
    set -u
    ${pkgs.jq}/bin/jq -r '.[].id' \
      < <(${pkgs.niri}/bin/niri msg -j windows 2>/dev/null) \
      | while read -r id; do
          ${pkgs.niri}/bin/niri msg action focus-window "$id" >/dev/null 2>&1 || continue
          ${pkgs.niri}/bin/niri msg action close-window    >/dev/null 2>&1
        done
  '';

  # Super+C/X/V 统一复制/剪切/粘贴
  # niri 没有内置 copy/paste 动作：图形应用自己绑 Ctrl+C/V/X，终端绑
  # Ctrl+Shift+C/V（Ctrl+C 在终端是中断信号）。niri-clip 查询焦点窗口的
  # app_id 判断是否终端，再用 wtype 虚拟键盘把按键翻译过去。
  # 能用的前提（已实测）：niri/Smithay 的修饰键状态按键盘设备分别维护，
  # 虚拟设备注入 Ctrl+C 时客户端只收到该设备自己的 Control，物理按住的
  # Super 不会混进去变成 Super+Ctrl+C。Hyprland 是 seat 级聚合，所以
  # omarchy 不能用 wtype、只能用自家的 send_key_state（见
  # omacom/omarchy 的 default/hypr/bindings/clipboard.lua）。
  niriClip = pkgs.writeShellScriptBin "niri-clip" ''
    set -u

    # 视为终端的 app_id，统一转小写后匹配
    # btop 是 foot 用 --app-id=btop 起的监控窗口，同样按终端按键处理
    # （否则 Super+C 会变成 Ctrl+C，直接把 btop 退出）
    TERMINALS="foot btop kitty org.gnome.terminal gnome-terminal-server blackbox com.gexperts.blackbox xterm org.wezfurl.wezterm"

    # wtype 参数序列：按下修饰键 → 敲字母键 → 松开修饰键
    case "$1" in
        copy)  gui="-M ctrl -k c -m ctrl"; term="-M ctrl -M shift -k c -m shift -m ctrl" ;;
        cut)   gui="-M ctrl -k x -m ctrl"; term="-M ctrl -M shift -k x -m shift -m ctrl" ;;
        paste) gui="-M ctrl -k v -m ctrl"; term="-M ctrl -M shift -k v -m shift -m ctrl" ;;
        *) printf 'usage: niri-clip {copy|cut|paste}\n' >&2; exit 1 ;;
    esac

    appid=$(niri msg -j focused-window 2>/dev/null \
        | grep -o '"app_id":"[^"]*"' | head -1 | cut -d'"' -f4 \
        | tr '[:upper:]' '[:lower:]')

    keys=$gui
    for t in $TERMINALS; do
        if [ "$appid" = "$t" ]; then
            keys=$term
            break
        fi
    done

    exec wtype $keys
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

    # 配色文件部署到独立目录（不能放在 niri/ 下，因为
    # ~/.config/niri 是 symlink 指向 $HOME 外的 git 仓库）。
    # 注意：config.kdl 中使用 ~/.config/niri-colors/ 绝对路径而非
    # ../niri-colors/ 相对路径，因为 niri 解析 include 时会跟随
    # symlink 链，导致 .. 解析到 git 仓库父目录而非 ~/.config/。
    # outputs.kdl 同理：按主机区分的内容也无法放进被 symlink 的共享目录。
    xdg.configFile."niri-colors/layout.kdl".text = layoutKdl;
    xdg.configFile."niri-colors/overview.kdl".text = overviewKdl;
    xdg.configFile."niri-outputs/outputs.kdl".text = outputsKdl;

    home.packages = [
      pkgs.wtype
      niriClip
      niriCloseAll
    ];
  };
}
