# Niri 窗口管理器 — 用户级配置文件部署
{
  lib,
  config,
  osConfig,
  pkgs,
  inputs,
  ...
}:
let
  guiCfg = config.mengw.gui;
  niriConfigPath = "${config.home.homeDirectory}/Projects/nixos-config/modules/home-manager/gui/wm/config";

  # ── 桌面壳层调色板 ──────────────────────────────────────────────────────
  # 只服务于 niri 自身的窗口装饰（焦点环 / 标签指示器 / 概览背景 / 插入提示）。
  # 全部取自 GTK/Qt 侧同一来源：MacTahoe-Dark 的
  #   share/themes/MacTahoe-Dark/gtk-4.0/gtk.css
  # 括号内是该色在上述 CSS 里的出现次数，可直接 grep 复核。
  #
  # 此前这里用的是 Gruvbox Dark：暖调、高饱和，而它驱动的偏偏是桌面饱和度最高的
  # 像素（当时是 3px 的焦点环），与窗口内容（Catppuccin Frappe，冷调低饱和）色相
  # 相反，结果是装饰抢了内容的注意力。现按 macOS 范式收敛：强调色只用**一个**
  # 扁平色、不再用红→橙双色渐变；而窗口边界（焦点环）根本不用强调色，
  # 改中性发丝线 —— 理由见 layoutKdl 里的 focus-ring 注释。
  #
  # 终端 / 编辑器 / Noctalia 各自的配色不在此列（见各自模块）：
  # 壳层不引入第二套品牌色。
  shell = {
    accent = "#0088FF"; # 主强调色 (112)
    dim = "#afafaf"; # 次要前景，用于非焦点标签指示器 (13)
    surface = "#333333"; # 次级表面，用于非焦点焦点环 (54)
    backdrop = "#242424"; # 主表面，用于概览背景 (73)
    red = "#ED5F5D"; # 错误 / 紧急 (30)
    # 中性发丝线，只给焦点环用（见 layoutKdl 里的说明）。
    # 两个依据：MacTahoe-Dark 的 gtk-4.0/gtk.css 里有 #999999；
    # niri 自己也把这个中性灰当作 recent-windows 高亮框的默认色
    # （default-config.kdl 的 highlight { active-color "#999999ff" }）。
    hairline = "#999999";
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
        //
        // 颜色不用强调色，而是中性发丝线。理由：Apple 从不把强调色放在窗口
        // 边界上 —— macOS 用强调色标**控件**（按钮、输入框焦点、选中的列表行），
        // 窗口边界只靠中性发丝线（主题里就是 rgba(255,255,255,.15) 那一条）
        // 加阴影区分活动与否。此前的 3px 饱和蓝边是整套改造里唯一“不像 macOS”
        // 的地方，也正因为它由单个高饱和色构成而显得抢眼。
        //
        // 宽度取 2 而不是 3：niri 会把逻辑像素按缩放取整到物理像素，desktop 的
        // 1.5 缩放下 3 → 4.5，落在半像素边界上（只能跳成 4 或 5，即实际 2.67~3.33）；
        // 而 2 → 3.0 精确。laptop 的 1.25 缩放下 2 → 2.5 仍不精确，
        // 两个主机都精确的值只有 4、8（那又太粗）。
        //
        // 为何不靠降不透明度来减重：焦点环画在 16px 缝隙上，背景就是壁纸。
        // 实测 45% 的不透明度压在亮壁纸（#FFFFFF）上会得到 #8CC9FF ——
        // 亮度与壁纸几乎相同，焦点提示直接失效。所以减重只能靠宽度和色相。
        //
        // #999999 能在亮暗两种壁纸上都立得住（暗壁纸 5.4:1、亮壁纸 2.9:1），
        // 而纯白太亮时会在亮壁纸上消失。想换回强调色就把 active-color
        // 改回 ${shell.accent}；想恢复原来的粗细就把 width 改回 3。
        focus-ring {
            on          // 开启焦点环
            width 2     // 2 × 1.5 = 3 物理像素，无取整误差
            active-color "${shell.hairline}"
            // 注意：焦点环只围绕每块显示器上的活动窗口，inactive-color 仅在
            // **非焦点显示器**上可见，单显示器永远看不到（niri wiki:
            // Configuration: Layout）。故取中性表面色，让非焦点显示器上的窗口
            // 轮廓退到背景里，而不是像原来那样用饱和青蓝。
            inactive-color "${shell.surface}"
            // niri 默认是深栗色 #9b0000，在深色桌面上几乎看不见；
            // 这一条是语义色不是装饰色，维持红色
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

        // 阴影：由合成器统一提供。
        //
        // 这不是“叠加”第二层阴影。niri 文档明说：设了 prefer-no-csd 与/或
        // geometry-corner-radius 之后，"These will also remove client-side
        // shadows if the window draws any" —— clip-to-geometry 裁的是
        // xdg_surface 的 window geometry（不含阴影边距），所以 CSD 自绘阴影
        // 已整层消失，这里是唯一的一层。
        // 也因此所有窗口（GTK / Electron / X11）共用同一套阴影，与 macOS 一致；
        // 而且窗口无论响应 prefer-no-csd 与否，结论都一样：
        //   GTK 保留 CSD → 自绘阴影被裁，合成器补上
        //   GTK 放弃 CSD → 本来就没有自绘阴影，合成器提供
        //
        // draw-behind-window 保持默认的 false：文档说因为 niri 不知道 CSD 圆角
        // 才需要 true 来遮住方形角的伪影；而我们给了 geometry-corner-radius，
        // niri 自己知道圆角，不需要“画到窗口后面”，也就不会在半透明窗口
        // （foot 0.85）里透出一圈暗影。
        //
        // 取值由 MacTahoe 自己的 CSD 阴影反推（gtk-4.0/gtk.css 的 window.csd）：
        //     0  3px  6px rgba(0,0,0,.15)
        //     0  7px 24px rgba(0,0,0,.12)
        //     0 12px 32px rgba(0,0,0,.08)
        //     0 0 0 2px rgba(0,0,0,.03) / 0 0 0 1px rgba(0,0,0,.12)  ← 两层“环”
        // 单层阴影无法复现三层叠加，所以：
        //   softness 32  = 最大 blur，用以匹配最远的衰减尾
        //   offset y=7   = 三层偏移 3/7/12 按各自 alpha 加权的中值
        //   spread 0     = 三层模糊层的 spread 都是 0
        //   color ≈ 35%  = 三层在窗沿处叠加后的等效不透明度
        // 那两层 0-blur 的“环”不另设 spread：它们等价于一条硬边，
        // 而主题的 outline（rgba(255,255,255,.15) 发丝边）已经在做这件事。
        // 不设 inactive-color：默认按更透明的 color 画，非焦点窗口阴影自动变淡。
        shadow {
            on
            softness 32
            spread 0
            offset x=0 y=7
            color "#00000059"
        }
    }
  '';

  # 生成的 overview.kdl
  overviewKdl = ''
    // 概览
    overview {
        // 0.50：文字可读，保留一定信息量，兼顾全局视野
        zoom 0.50
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

  # 生成的 outputs.kdl —— 由主机声明的 mySystem.desktop.monitors 数据驱动
  # （hosts/<host>/default.nix）。此前这里按 hostName switch 硬编码两台主机
  # 的输出，显示器数据泄漏进共享模块；现模块只做生成器，数据留在主机。
  # niri 的 output 段按物理输出名匹配，未连接的输出条目会静默失效，
  # 故每台主机只声明自己实际连接的屏幕；focus-at-startup 由数据控制，
  # 多输出主机只应在一项上开启。
  outputsKdl =
    let
      monitors = osConfig.mySystem.desktop.monitors;
      monitorKdl =
        m:
        let
          # toJSON 而非 toString：新版 Nix 的 toString 对 float 固定输出 6 位
          # 小数（1.5 → "1.500000"），KDL 虽能解析但可读性差；toJSON 给最短表示
          scaleStr = builtins.toJSON m.scale;
        in
        lib.concatStringsSep "\n" (
          [ "output \"${m.name}\" {" ]
          ++ lib.optionals (m.mode != null) [ "    mode \"${m.mode}\"" ]
          ++ [ "    scale ${scaleStr}" ]
          ++ lib.optionals (m.position != null) [
            "    position x=${toString m.position.x} y=${toString m.position.y}"
          ]
          ++ lib.optionals m.focus [ "    focus-at-startup" ]
          ++ [ "}" ]
        );
    in
    if monitors == [ ] then
      throw "mengw.gui.wm: 主机未声明 mySystem.desktop.monitors，无法生成 niri outputs.kdl"
    else
      lib.concatMapStringsSep "\n" monitorKdl monitors;

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

  # Super+C/X/V 的终端例外（键位本体定义在
  # modules/nixos/desktop/niri/default.nix 的 keyd 配置里）
  # keyd 在 evdev 层把 Super+C/X/V 重映射成 Ctrl+C/X/V，对所有客户端一视同仁，
  # 但它看不到谁有焦点；而终端要的是 Ctrl+Shift+C/X/V（Ctrl+C 在终端是 SIGINT，
  # 会直接把前台进程打断）。这里监听 niri 的焦点变化，用 `keyd bind` 覆写 meta
  # 层的这三个键：焦点是终端 → C-S-*，其余（含没有窗口获得焦点的面板态）→
  # reset 回 keyd 的静态配置。换终端只需改下面的 TERMINALS。
  keydAppNiri = pkgs.writeShellScriptBin "keyd-app-niri" ''
    set -u

    # 视为终端的 app_id，统一转小写后匹配
    # btop 是 foot 用 --app-id=btop 起的监控窗口，同样按终端按键处理
    TERMINALS="foot btop kitty org.gnome.terminal gnome-terminal-server blackbox com.gexperts.blackbox xterm org.wezfurl.wezterm"

    niri=${pkgs.niri}/bin/niri
    keyd=${pkgs.keyd}/bin/keyd
    jq=${pkgs.jq}/bin/jq

    # 上一次生效的映射，用来吃掉重复的焦点事件
    state=
    apply() {
      appid=$("$niri" msg -j focused-window 2>/dev/null \
        | "$jq" -r '.app_id // ""' | tr '[:upper:]' '[:lower:]')

      want=gui
      for t in $TERMINALS; do
        if [ "$appid" = "$t" ]; then
          want=term
          break
        fi
      done
      if [ "$want" = "$state" ]; then
        return 0
      fi

      if [ "$want" = term ]; then
        set -- 'meta.c = C-S-c' 'meta.x = C-S-x' 'meta.v = C-S-v'
      else
        set -- reset
      fi

      # 只在成功时记状态：keyd 未就绪（或无 socket 权限）时留待下次焦点变化重试
      if "$keyd" bind "$@"; then
        state=$want
      else
        echo "[keyd-app-niri] keyd bind 失败：keyd 未运行或缺 socket 权限（keyd 组）" >&2
      fi
    }

    # 先按启动时的焦点定一次，避免首个焦点变化前落在静态（GUI）映射上
    apply

    # event-stream 是逐行 JSON。只拿焦点变化当触发，app_id 一律现查：
    # WindowFocusChanged 只带 id，且并发切换时以最新焦点为准更安全。
    "$niri" msg -j event-stream | while read -r event; do
      case "$event" in
        *WindowFocusChanged*) apply ;;
      esac
    done
  '';
in
{
  imports = [
    ./noctalia.nix
  ];

  # 门控：mengw.gui.enable 控制整个 GUI 层，无中间层开关
  config = lib.mkIf guiCfg.enable {
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
      # keyd CLI：watcher 用 `keyd bind` 切换键位，手动排查也用得上
      # （`keyd bind reset` 复位、`keyd listen` 看层状态）
      pkgs.keyd
      keydAppNiri
      niriCloseAll
    ];

    # 焦点变化时切换 keyd 的键位（终端走 Ctrl+Shift+C/X/V）
    # 键位本体在 NixOS 侧的 services.keyd 里；主机没开 keydClipboard
    # （默认会话不是 niri，watcher 收不到焦点事件）就不必起这个服务。
    systemd.user.services.keyd-app-niri = lib.mkIf osConfig.mySystem.desktop.niri.keydClipboard.enable {
      Unit = {
        Description = "按焦点应用切换 keyd 的 Super+C/X/V 映射";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${keydAppNiri}/bin/keyd-app-niri";
        # niri 的 socket 与 keyd 都可能尚未就绪，失败即重来
        Restart = "always";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
