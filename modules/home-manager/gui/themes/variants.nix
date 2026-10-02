# 亮 / 暗两套外观 —— 单一真源是 Noctalia 的 theme mode
# （状态栏那个主题图标切的就是它：noctalia msg theme-mode-toggle）
#
# 为什么需要这一层：主题取值此前全部钉死在 Nix 里（MacTahoe-Dark / MacTahoeDark /
# 深色调色板），而运行时切换需要**可写的目标文件**，那几个文件都是 HM 的 store 软链
# （gtk-3.0/settings.ini、gtk-4.0/{settings.ini,gtk.css}、Kvantum/kvantum.kvconfig、
# niri-colors/*.kdl）。做法：把**两套变体都生成到 store**，脚本只把当前模式对应的
# 软链指过去 —— Nix 仍然持有全部取值，运行时只有一个「哪一套」的选择。
#
# 归属约定（一个文件只有一个主人）：
#   - HM 写初始值（= 暗色，与改造前一致）+ 两套变体（~/.config/theme-variants/…）
#   - theme-apply 只做一件事：把上面那几个软链指到当前模式的变体，并写 dconf
#   - 于是 rebuild 后回到暗色，登录时的 theme-apply 再按 Noctalia 的模式纠正，
#     不需要任何「哪套生效中」的状态文件（脚本幂等，见下方 link()）
#
# 为什么监听**目录**而不是文件：Noctalia 保存 settings.toml 是 temp+rename
# （实测 toggle 前后 inode 变了），盯文件的 PathModified 会漏事件；盯目录能抓到 rename。
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mengw.gui.themes;
  guiCfg = config.mengw.gui;

  home = config.home.homeDirectory;
  variantDir = "theme-variants";

  # 一套模式的全部取值。改主题只改这里。
  # GTK 变体名取自包里的实际目录：share/themes/{MacTahoe-Dark,MacTahoe-Light}；
  # 图标主题是小写后缀 {MacTahoe-dark,MacTahoe-light}；
  # Kvantum 上游只有浅深两态，深色那对被单独命名为 MacTahoeDark
  # （命名理由见 pkgs/mactahoe-kvantum 顶部）。
  modes = {
    dark = {
      gtk = "MacTahoe-Dark";
      icons = "MacTahoe-dark";
      kvantum = "MacTahoeDark";
    };
    light = {
      gtk = "MacTahoe-Light";
      icons = "MacTahoe-light";
      kvantum = "MacTahoe";
    };
  };

  # 窗口按钮放左侧、macOS 顺序（红黄绿）—— 与 Thunderbird 统一（LiquidBird 用 order
  # 把三个点钉在物理左边缘，见其 linux/titlebuttons.css）。
  # 只有这条路管用：实测把 gtk-decoration-layout 写进 settings.ini 对 libadwaita 应用
  # 无效（GTK4 的这个值不从 ini 读），真正被读的是 dconf 的
  # org.gnome.desktop.wm.preferences button-layout —— GNOME Tweaks 改的也是它。
  buttonLayout = "close,minimize,maximize:";

  # 与 HM 的 gtk 模块对同一模式写出的内容保持一致（modules/misc/gtk/lib.nix）：
  # gtk-application-prefer-dark-theme 只在暗色出现，gtk-interface-color-scheme 只 GTK4 有。
  gtkIni =
    version: mode:
    let
      m = modes.${mode};
    in
    ''
      [Settings]
      ${
        lib.optionalString (mode == "dark") "gtk-application-prefer-dark-theme=true\n"
      }gtk-cursor-theme-name=Bibata-Modern-Classic
      gtk-cursor-theme-size=24
      gtk-decoration-layout=${buttonLayout}
      gtk-font-name=HarmonyOS Sans SC 12
      gtk-icon-theme-name=${m.icons}
      ${lib.optionalString (version == 4) "gtk-interface-color-scheme=${mode}\n"}gtk-theme-name=${m.gtk}
    '';

  # 模式无关的 GTK4 用户样式：GTK 只在**启动时读一次**这个文件（GtkCssProvider 文档
  # 原话），所以不能把亮/暗做成两个文件 —— 否则运行中的程序拿到新 color-scheme 后，
  # 里面已经解析进去的还是旧那份调色板（实测：只有一侧变亮）。
  # 改为「结构取 MacTahoe-Dark + 整份 MacTahoe-Light 放进 @media」，媒体查询自 GTK 4.20
  # 起支持（本机 4.22.4），color-scheme 一变就会重算 —— 文件本身永远不需要换。
  # 两个变体除颜色值外同构（125 条 @define-color + 约 1300 行内联颜色），故整份覆盖是安全的。
  #
  # 内联那份的相对 url("windows-assets/…") 必须改写成绝对 file://：相对路径以
  # **本文件**的 URI 为基准解析，不改写则亮色下红黄绿灯那套 PNG 全找不到（实测消失）。
  # 另：黄灯“不亮”不在这里改 —— 最小化按钮在 niri 上无对应动作、被 GTK 置为 disabled，
  # 减淡由 GTK 自身施加（opacity/filter/-gtk-icon-filter 加 !important 覆盖后像素
  # 完全不变，已实测）。
  gtk4UserCss = pkgs.runCommand "gtk-user.css" { } ''
        theme=${pkgs.mactahoe-gtk-theme}/share/themes
        light="$theme/MacTahoe-Light/gtk-4.0"
        {
          echo '/* 由 Home Manager 生成 —— modules/home-manager/gui/themes/variants.nix */'
          echo '/* 结构：MacTahoe-Dark；浅色：整份 MacTahoe-Light 覆盖在 @media 里 */'
          echo "@import url(\"file://$theme/MacTahoe-Dark/gtk-4.0/gtk.css\");"
          echo '@media (prefers-color-scheme: light) {'
          # 内联进来的浅色那份，相对 url("windows-assets/…") 会以**本文件**的 URI 为基准解析
          # （GTK 不会 realpath 软链、也不会把 @media 里的相对路径重挂到源目录），
          # 于是红黄绿灯那套 PNG 找不到 —— 实测亮色下三个灯直接消失。
          # 而 @import 那一行是绝对 file://，它的相对路径本就落在主题目录里，不用改。
          sed -E 's|url\("([a-zA-Z][^":]*)"\)|url("file://'"$light"'/\1")|g' "$light/gtk.css"
          echo '}'

          # 最小化按钮在 niri 上没有对应动作（niri 无 minimize），GTK 把它置为 disabled；
          # MacTahoe 没给这三个窗口按钮写 :disabled 样式，于是落到基础样式表的
          # ~30% 不透明度 —— 黄灯看起来“不亮”（实测采样：亮黄 #F1AE1B 被压到 97,77,33）。
          # 这里把它改回实心，与红/绿两灯一致；代价是点它没有反应（动作本就不存在），
          # 不想要这种“视觉上说谎”就删掉下面这段。
          cat <<'CSS'

    /* 黄灯（minimize）：niri 无最小化，去掉 disabled 的减淡，让它与红/绿一致 */
    headerbar windowcontrols button.minimize:disabled,
    headerbar windowcontrols button.minimize:disabled image {
      -gtk-icon-filter: none;
      opacity: 1;
    }
    CSS
        } > $out
  '';

  # GTK4 只认 color-scheme，主题本体靠上面的 import（HM 的 gtk4.theme 就是这么做的）
  kvconfig = mode: ''
    [Applications]

    [General]
    theme=${modes.${mode}.kvantum}
  '';

  variants = {
    "${variantDir}/gtk-3.0/dark.ini".text = gtkIni 3 "dark";
    "${variantDir}/gtk-3.0/light.ini".text = gtkIni 3 "light";
    "${variantDir}/gtk-4.0/dark.ini".text = gtkIni 4 "dark";
    "${variantDir}/gtk-4.0/light.ini".text = gtkIni 4 "light";
    "${variantDir}/kvantum/dark.kvconfig".text = kvconfig "dark";
    "${variantDir}/kvantum/light.kvconfig".text = kvconfig "light";
  };

  applyScript = pkgs.writeShellApplication {
    name = "theme-apply";
    runtimeInputs = [
      pkgs.coreutils
      # 下面用 awk 解析 settings.toml；coreutils 不带 awk，不显式给的话
      # runtimeInputs 造的 PATH 里就没有它，服务里 mode 取空、直接撞 case 退出
      pkgs.gawk
      pkgs.glib # gsettings
      pkgs.dconf # dconf 后端（否则 gsettings 写进内存后端，重启即丢）
      # 重启 fcitx5 那段用的两个命令：不能指望继承来的 PATH 里有它们
      # （systemd 用户服务的 PATH 与交互式 shell 不同，缺了就静默不重启）
      pkgs.procps # pgrep
      pkgs.util-linux # setsid
    ];
    text = ''
            # 参数可显式给模式（排查用）：theme-apply light
            mode="''${1-}"
            if [ -z "$mode" ]; then
              state="''${XDG_STATE_HOME:-$HOME/.local/state}/noctalia/settings.toml"
              # 只读 [theme] 段里的 mode；文件不存在或未写该键时保持暗色
              mode="$(awk -F'"' '/^\[/{s=($0=="[theme]")} s && /^mode *=/ {print $2; exit}' "$state" 2>/dev/null)"
            fi
            case "$mode" in
              light | dark) ;;
              *) echo "theme-apply: 未知模式 '$mode'（取自 Noctalia state），保持现状" >&2; exit 1 ;;
            esac

            # 幂等：已经是这个目标就不动，避免 path 单元每次触发都让 niri 重载。
            # 目标不存在就报错退出：上一次就是把变体路径写少了 .config/，脚本默默把软链
            # 指到不存在的文件，niri 因为 include 读不到而**整份配置拒绝加载**，
            # 现象却是「某些改动没生效」，很难往这里想。
            # flipped 记录「本次是否真翻了东西」：只有真翻了才值得去重启 fcitx5 —— path 单元
            # 会被 settings.toml 的任何改动触发，每次都重启 IME 会很烦人。
            flipped=0
            link() {
              if [ ! -e "$2" ]; then
                echo "theme-apply: 变体不存在：$2（登记的目标路径写错了？）" >&2
                exit 1
              fi
              if [ "$(readlink "$1" 2>/dev/null)" != "$2" ]; then
                ln -sfn "$2" "$1"
                flipped=1
              fi
            }

            # 本模块自己那五个 + 各层登记进来的（ghostty / btop / …）：case 同时把模式相关的
            # 取值（dconf 的 scheme 与 gtk/icon 主题名）定下来
            case "$mode" in
              dark)
                scheme=prefer-dark
                gtk="${modes.dark.gtk}"
                icons="${modes.dark.icons}"
      ${lib.concatMapStringsSep "\n" (
        t: "          link \"$HOME/${t.live}\" \"$HOME/${t.dark}\""
      ) config.mengw.appearance.switchTargets}
                ;;
              light)
                scheme=prefer-light
                gtk="${modes.light.gtk}"
                icons="${modes.light.icons}"
      ${lib.concatMapStringsSep "\n" (
        t: "          link \"$HOME/${t.live}\" \"$HOME/${t.light}\""
      ) config.mengw.appearance.switchTargets}
                ;;
            esac

            # dconf 侧：GTK4/libadwaita 只认 color-scheme，xdg-desktop-portal 也从这里读，
            # 所以 Electron / 跟随系统的应用看的是这几个键。
            # 注意与 HM 写 dconf 的值同形（org.gnome.desktop.interface）。
            #
            # 两个必须显式给的路径 —— 否则在 systemd 用户服务的环境里会静默地写进
            # 内存后端（实测：clean env 下 gsettings 直接报「No schemas installed」，
            # 加 schema 目录后又因找不到 dconf 模块而回退到内存后端，重启即丢）：
            #   1. schema 搜索路径（GLib 不从 PATH 推）
            #   2. dconf 的 GIO 模块（GSETTINGS_BACKEND=dconf 靠它）
            schema_dir="$(echo ${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/*/glib-2.0/schemas)"
            if [ -d "$schema_dir" ]; then
              export GSETTINGS_SCHEMA_DIR="$schema_dir''${GSETTINGS_SCHEMA_DIR:+:$GSETTINGS_SCHEMA_DIR}"
            fi
            export GSETTINGS_BACKEND=dconf
            # lib.getLib：dconf 的 GIO 模块在 **-lib 输出**里，写 ${pkgs.dconf}/lib/... 会指向
            # out 输出 —— 那样 gsettings 找不到模块，却仍然退出 0（静默写进内存后端，重启即丢）。
            export GIO_EXTRA_MODULES="${lib.getLib pkgs.dconf}/lib/gio/modules''${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}"
            gsettings set org.gnome.desktop.interface color-scheme "$scheme"
            gsettings set org.gnome.desktop.interface gtk-theme "$gtk"
            gsettings set org.gnome.desktop.interface icon-theme "$icons"
            # 窗口按钮位置与亮/暗无关，但一并写：HM 只在 activation 时写一次，
            # dconf 被别的东西（GNOME 系工具、临时脚本）改过之后不会自己回去。
            gsettings set org.gnome.desktop.wm.preferences button-layout "${buttonLayout}"

            # 回读校验：dconf 后端不可用时 gsettings 会静默写进内存后端（退出码仍为 0），
            # 那时「跟随系统的应用」永远不跟，而日志里一点异常都没有。
            got="$(gsettings get org.gnome.desktop.interface color-scheme)"
            if [ "$got" != "'$scheme'" ]; then
              echo "theme-apply: dconf 写入未生效（color-scheme 回读为 $got）—— 查 GIO_EXTRA_MODULES 里的 dconf 模块" >&2
              exit 1
            fi

            # ghostty 不需要这里的信号：它的 theme 写成「亮:主题,暗:主题」一对，
            # 由 ghostty 自己按桌面主题选（读的正是上面写的 dconf color-scheme），
            # 新窗口天然跟随。其它 TUI（btop 等）无热重载，下次启动生效。
            #
            # fcitx5 的候选窗主题**只在启动时读一次**（热重载不会重套主题），所以真翻了配置就
            # 必须真重启它。
            #
            # 判断它在不在跑**不能用 pgrep -x fcitx5**：NixOS 的 fcitx5 是包装脚本，进程名是
            # .fcitx5-wrapped（实测；pgrep -x fcitx5 永远为假，于是整段重启逻辑静默失效，
            # 现象就是「切主题后要手动重启 IME 才换皮肤」）。改成问 D-Bus 名字归属 ——
            # 那也正是新实例要抢的资源，所以这个判断和失败原因是同一件事。
            # 两道判断取或：gdbus 问 D-Bus 名字归属是最准的，但它依赖 glib 的 bin 与
            # 会话总线都在服务环境里可见 —— 实测在服务里它返回假，于是整段被静默跳过
            # （服务报成功、conf 也翻了，就是 IME 不动，最难查）。所以补一道纯进程名兜底：
            # NixOS 的 fcitx5 进程名是 .fcitx5-wrapped，两种名字都匹配。
            fcitx5_running() {
              gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus \
                --method org.freedesktop.DBus.NameHasOwner org.fcitx.Fcitx5 2>/dev/null | grep -q true ||
                pgrep -x '.fcitx5-wrapped|fcitx5' >/dev/null 2>&1
            }
            # 用系统里那对**包装版**命令（就是你平时敲的 fcitx5 / fcitx5-remote），不要用
            # pkgs.fcitx5 的裸二进制：裸的 fcitx5-remote 未必能跟包装版实例说上话，于是
            # 重启悄悄没发生；而「重启后有没有起来」的检查看到旧实例还在，就报了成功。
            ime=/run/current-system/sw/bin/fcitx5
            remote=/run/current-system/sw/bin/fcitx5-remote
            [ -x "$ime" ] || ime="${pkgs.fcitx5}/bin/fcitx5"
            [ -x "$remote" ] || remote="${pkgs.fcitx5}/bin/fcitx5-remote"
            if [ "$flipped" = 1 ] && fcitx5_running; then
              "$remote" -e 2>/dev/null || true
              for _ in $(seq 20); do
                fcitx5_running || break
                sleep 0.25
              done
              # 它赖着不退（-e 不生效）就直接给它信号 —— 本意本来就是重启 IME，
              # 留着旧实例等于「皮肤不换」，那是这个特性唯一要避免的事。
              if fcitx5_running; then
                pkill -x '.fcitx5-wrapped|fcitx5' 2>/dev/null || true
                for _ in $(seq 20); do
                  fcitx5_running || break
                  sleep 0.25
                done
              fi
              setsid "$ime" -d >/dev/null 2>&1 || true
              sleep 2
              if ! fcitx5_running; then
                setsid "$ime" -d >/dev/null 2>&1 || true # 再给一次机会
                sleep 2
              fi
              if ! fcitx5_running; then
                echo "theme-apply: fcitx5 重启后未起来（主题已翻，但 IME 需要手动跑 fcitx5 -d）" >&2
                exit 1
              fi
            fi
    '';
  };
in
{
  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    # 本模块自己那五个活文件也走同一张表（见 modules/home-manager/default.nix 的
    # mengw.appearance.switchTargets）：theme-apply 只做「指软链」，不认具体应用。
    # gtk.css 不在表里：它是模式无关的单一文件（见上面 gtk4UserCss）。
    mengw.appearance.switchTargets = [
      {
        live = ".config/gtk-3.0/settings.ini";
        dark = ".config/${variantDir}/gtk-3.0/dark.ini";
        light = ".config/${variantDir}/gtk-3.0/light.ini";
      }
      {
        live = ".config/gtk-4.0/settings.ini";
        dark = ".config/${variantDir}/gtk-4.0/dark.ini";
        light = ".config/${variantDir}/gtk-4.0/light.ini";
      }
      {
        live = ".config/Kvantum/kvantum.kvconfig";
        dark = ".config/${variantDir}/kvantum/dark.kvconfig";
        light = ".config/${variantDir}/kvantum/light.kvconfig";
      }
      # niri 的配色是 include 进来的两个文件，niri 自己会 watch 到并重载
      {
        live = ".config/niri-colors/layout.kdl";
        dark = ".config/${variantDir}/niri/layout-dark.kdl";
        light = ".config/${variantDir}/niri/layout-light.kdl";
      }
      {
        live = ".config/niri-colors/overview.kdl";
        dark = ".config/${variantDir}/niri/overview-dark.kdl";
        light = ".config/${variantDir}/niri/overview-light.kdl";
      }
    ];

    xdg.configFile = variants // {
      # 模式无关：GTK4 的亮/暗在同一份文件里靠 @media 切（不能靠换文件，见 gtk4UserCss）
      "gtk-4.0/gtk.css".source = gtk4UserCss;
    };

    home.packages = [ applyScript ];

    # 窗口按钮放左侧：dconf 才是真源（settings.ini 那个键对 libadwaita 应用无效，
    # 见上面 buttonLayout 的注释）
    dconf.settings."org/gnome/desktop/wm/preferences".button-layout = buttonLayout;

    # 登录时按当前模式应用一次；此后 Noctalia 的 state 目录一变就再来一次
    systemd.user.services.theme-apply = {
      Unit = {
        Description = "应用 Noctalia 的亮/暗模式到 GTK/Qt/图标/niri";
        # 不要限流：一旦失败，systemd 会让 path 单元后续触发全丢
        # （实测连续 3 次失败后 start-limit-hit，之后 toggle 再也不生效，
        # 而现象只是「部分应用没跟上」，很难联想到限流）。
        # 这个单元每次只翻几个软链，失败就该能重试。
        StartLimitIntervalSec = 0;
        StartLimitBurst = 0;
      };
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe applyScript;
      };
      Install.WantedBy = [ "default.target" ];
    };

    systemd.user.paths.theme-apply = {
      Unit.Description = "监听 Noctalia theme mode 的变化（temp+rename，故盯目录）";
      Path.PathModified = "${home}/.local/state/noctalia";
      Install.WantedBy = [ "default.target" ];
    };
  };
}
