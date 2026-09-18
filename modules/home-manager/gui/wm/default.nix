# Niri 窗口管理器 — 用户级配置文件部署
{ lib, config, osConfig, pkgs, inputs, ... }:
let
  cfg = config.mengw.gui.wm;
  guiCfg = config.mengw.gui;
  niriConfigPath = "${config.home.homeDirectory}/Projects/nixos-config/modules/home-manager/gui/wm/config";

  # ── 桌面壳层调色板 ──────────────────────────────────────────────────────
  # 只服务于 niri 自身的窗口装饰（焦点环 / 标签指示器 / 概览背景 / 插入提示）。
  # 全部取自 GTK/Qt 侧同一来源：MacTahoe-Dark 的
  #   share/themes/MacTahoe-Dark/gtk-4.0/gtk.css
  # 括号内是该色在上述 CSS 里的出现次数，可直接 grep 复核。
  #
  # 此前这里用的是 Gruvbox Dark：暖调、高饱和，而它驱动的偏偏是桌面饱和度最高的
  # 像素（3px 焦点环），与窗口内容（Catppuccin Frappe，冷调低饱和）色相相反，
  # 结果是装饰抢了内容的注意力。现按 macOS 范式收敛为**单一扁平强调色**，
  # 不再用红→橙双色渐变。
  #
  # 终端 / 编辑器 / Noctalia 各自的配色不在此列（见各自模块）：
  # 壳层不引入第二套品牌色。
  shell = {
    accent = "#0088FF"; # 主强调色 (112)
    dim = "#afafaf"; # 次要前景，用于非焦点标签指示器 (13)
    surface = "#333333"; # 次级表面，用于非焦点焦点环 (54)
    backdrop = "#242424"; # 主表面，用于概览背景 (73)
    red = "#ED5F5D"; # 错误 / 紧急 (30)
  };

  # 生成的 layout.kdl
  layoutKdl = ''
    // niri 窗口布局配置
    // https://niri-wm.github.io/niri/Configuration%3A-Layout.html
    layout {
        // 窗口之间、以及窗口与屏幕边缘的间距（逻辑像素）。
        // 取 16 是因为窗口圆角是 12（见 windowrules.kdl 的 geometry-corner-radius）：
        // 间距小于圆角时，相邻两窗的圆角弧比它自己的半径还靠得近，缝隙看上去是
        // “被掐住”而不是留白（8 逻辑像素在 1.5 缩放下 = 12 物理像素，只有 24
        // 物理像素圆角的一半）。16 能在两个圆角之间留出一段直边。
        //
        // 注意 gaps 同时作用于内缝隙与外留白；若以后想两者不同（外小内大），
        // niri 的官方写法是 gaps 16 配 struts { left/right/top/bottom -8; }，
        // 这里没有采用——本机没有用 open-maximized-to-edges，但负 struts 会把
        // 平铺区推到屏幕外，不想引入这个边界情况。
        gaps 16
        background-color "transparent"  // 工作区透明
        center-focused-column "never"   // 无特殊居中效果
        // 单列工作区居中：有意为之的“专注模式”——一个窗口时留在屏幕中间保持
        // 可读宽度，而不是铺满。想铺满不需要改这项：Mod+F 是 maximize-column，
        // Mod+Minus/Equal 以 5% 为步长手动调列宽。
        always-center-single-column
        // 新窗口的默认列宽（0.5 即 niri 自身的默认值，写明只是为了意图明确）
        default-column-width { proportion 0.5; }

        // 焦点环，用于指示活动窗口
        focus-ring {
            on          // 开启焦点环
            width 3     // 焦点环宽度
            // 单一扁平强调色，与 GTK/Qt 侧同源（macOS 范式：强调色不用渐变）
            active-color "${shell.accent}"
            // 注意：焦点环只围绕每块显示器上的活动窗口，inactive-color 仅在
            // **非焦点显示器**上可见，单显示器永远看不到（niri wiki:
            // Configuration: Layout）。故取中性表面色，让非焦点显示器上的窗口
            // 轮廓退到背景里，而不是像原来那样用饱和青蓝。
            inactive-color "${shell.surface}"
            // niri 默认是深栗色 #9b0000，在深色桌面上几乎看不见
            urgent-color "${shell.red}"
        }

        // 边框：与焦点环作用重叠，保持关闭，窗口指示只保留焦点环一种
        border {
            off
        }

        // 标签指示器：仅当列进入 tabbed 显示模式时出现（Mod+W）
        tab-indicator {
            on
            place-within-column // 指示器绘制列内部
            gap 5 // 指示器与窗口边缘间距
            width 3 // 指示器宽度
            length total-proportion=1.0 // 指示器长度占列总高度比例
            position "right" // 指示器在列的右侧
            gaps-between-tabs 2 // 多个标签指示器并排时间距
            // 指示器宽度只有 3px，而半径 8 > 宽度一半 ⇒ 两端自然成胶囊，
            // 与 MacTahoe 的"药丸"（border-radius 9999px）同一语义。
            // 阶梯见 windowrules.kdl 顶部的 concentricity 说明。
            corner-radius 8 // 指示器圆角半径
            active-color "${shell.accent}" // 焦点列
            // 非焦点列：指示器要说明"此列是 tabbed"，需在深色壁纸上可见，
            // 故用次要前景色而不是表面色
            inactive-color "${shell.dim}"
            urgent-color "${shell.red}" // 紧急
        }

        // 窗口插入提升
        insert-hint {
            on
            color "${shell.accent}80"
        }
    }
  '';

  # 生成的 overview.kdl
  overviewKdl = ''
    // 概览
    overview {
        zoom 0.40
        // 概览里工作区背后、以及切换工作区时露出的底色。
        // 注意 niri 会**忽略此色的 alpha 通道**（niri wiki: Configuration:
        // Miscellaneous），所以这里只能给不透明色，写成 #242424cc 无效。
        // 原来是 Gruvbox 的暖灰棕 #665c54：一大片中饱和暖色与所有窗口的冷调
        // 内容色温相反，缩略图会显得"糊在泥里"。改用中性深色。
        backdrop-color "${shell.backdrop}"
    }

    // 带缩略图的 Super+Tab 窗口切换器
    recent-windows {
        debounce-ms 750
        open-delay-ms 150

        highlight {
            // 焦点预览的高亮框；不设时是 niri 默认的中性灰 #999999
            active-color "${shell.accent}"
            urgent-color "${shell.red}"
            padding 30
            // 12 = MacTahoe 阶梯里的"独立弹层"档（popover / menu / osd）
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
