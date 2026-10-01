# Noctalia Shell 用户级配置
{
  lib,
  config,
  osConfig,
  inputs,
  ...
}:
let
  cfg = config.mengw.gui.wm.noctalia;
  guiCfg = config.mengw.gui;

  # DDC/CI 亮度：由主机声明的 mySystem.desktop.monitors 中 ddc = true 的输出
  # 派生（desktop 的外接屏 DP-2；需硬件支持且主机已开 hardware.i2c）。
  # 内屏 eDP 走 sysfs backlight；在不支持的主机上 enable_ddcutil 只会让
  # noctalia 反复跑必然失败的 ddcutil detect。
  ddcMonitors = lib.filter (m: m.ddc) osConfig.mySystem.desktop.monitors;
  useDdc = ddcMonitors != [ ];

  # ── 壁纸 ──────────────────────────────────────────────────────────────
  # 默认集来自系统层 mySystem.desktop.wallpapers（首项为默认壁纸），部署到
  # picker 浏览根下的独立子目录：与用户自己的图分开，同时仍是面板里可浏览的
  # 一层（面板把子目录列成条目）。
  #
  # "Pictures/wallpaper" 是相对形式：home.file 的键必须相对 $HOME，而面板要
  # 绝对路径，两者同源避免写两遍。
  wallpaperRootRel = "Pictures/wallpaper";
  wallpaperRoot = "${config.home.homeDirectory}/${wallpaperRootRel}";
  wallpaperSetRel = "${wallpaperRootRel}/默认集";
  wallpaperSet = "${config.home.homeDirectory}/${wallpaperSetRel}";
  wallpapers = osConfig.mySystem.desktop.wallpapers;

  # 发布后的真实路径，不是 store 路径：面板选中的路径会被写进 settings.toml，
  # 写 store 路径会在 rebuild 后指向一个可能已被 GC 的旧 hash。
  defaultWallpaper =
    if wallpapers == [ ] then
      throw "mengw.gui.wm.noctalia：mySystem.desktop.wallpapers 为空，无法确定默认壁纸"
    else
      "${wallpaperSet}/${baseNameOf (lib.head wallpapers)}";
in
{
  options.mengw.gui.wm.noctalia.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Noctalia Shell 用户级配置";
  };

  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    # 默认壁纸集部署进 picker 目录（见上方 wallpaperSet）
    home.file = lib.listToAttrs (
      map (w: lib.nameValuePair "${wallpaperSetRel}/${baseNameOf w}" { source = w; }) wallpapers
    );

    programs.noctalia = {
      enable = true;

      # ⚠️ 这里的 settings 只是**出厂默认值**：GUI 里的改动会写进
      # ~/.local/state/noctalia/settings.toml（运行时状态），并覆盖本文件对应键。
      # 模块文档原话："these settings can still be overwritten at runtime via the
      # settings menu"。故 bar 的布局（控件列表、胶囊、透明度）与插件配置不在此
      # 维护，那部分归 GUI；本模块只负责需要在版本控制里钉死的东西：调色板。
      # 实测被运行时覆盖的键见 docs/themes.md 的"Noctalia"一节。
      settings = {
        shell = {
          font_family = lib.mkForce "HarmonyOS Sans SC";
        };
        theme = {
          mode = "dark";
          # 用下面的自定义调色板，而不是内置/社区方案：只有自定义调色板能同时钉住
          # "MacTahoe 的中性灰"与"#0088FF 强调色"。
          # 注意：若 settings.toml 已有 theme.source，本项会被它覆盖，改后需在
          # Noctalia 外观面板选中一次，或跑
          #   noctalia msg color-scheme-set custom mactahoe
          source = lib.mkForce "custom";
          custom_palette = lib.mkForce "mactahoe";
        };
        wallpaper = {
          # picker 面板按此目录列图，不写则回落到 XDG Pictures（多一层目录）
          directory = wallpaperRoot;
          # 默认壁纸：新机器或状态里没有选择时生效。已有选择的主机要让它生效，
          # 跑一次 noctalia msg wallpaper-set <path>（见 docs/manager.md）
          default.path = defaultWallpaper;
        };
        # bar 布局：这四项可以声明式 —— 它们没有密钥（明文 API key 在 state 的
        # [plugin_settings."coder/deepseek_usage"] 段里，与本组无关）。bar 的其余键
        # （capsule / enabled / margin_edge / members …）仍归 GUI，本模块只钉这四项。
        # 取值理由与对比度算据见 docs/themes.md 的「bar 收敛」。
        # 注意：运行时 state 里已有同键会遮蔽这里，首次生效需把 state 那四行删一次
        # （见 docs/manager.md）。
        bar.default = {
          background_opacity = 0.30;
          start = [ "workspaces" ];
          center = [ "date" ];
          end = [
            "tray"
            "clipboard"
            "notifications"
            "volume"
            "brightness"
            "session"
          ];
        };
        # 不写 widget.cat.rave_mode：小部件本身（其 id 与 type）由 GUI 持有，
        # 只声明它的一个子键会在 config.toml 里生成一个无 type 的 [widget.cat] 段，
        # noctalia config validate 会报 `unrecognized widget type "cat"`。
        # 关掉 rave 动画改为 GUI 侧一次性步骤（见 docs/manager.md）。
        brightness = {
          enable_ddcutil = useDdc;
          # 每个声明了 ddc = true 的输出各生成一条 ddcutil 后端映射
          monitor = lib.mkIf useDdc (
            lib.listToAttrs (map (m: lib.nameValuePair m.name { backend = "ddcutil"; }) ddcMonitors)
          );
        };
        audio = {
          # 不写 enable：noctalia 1.0 的配置校验把它判为 "unknown setting"
          # （noctalia config validate 实测报 audio.enable: unknown setting）
          enable_overdrive = true;
          enable_sounds = false;
          # 不写 sound_volume / volume_change_sound / notification_sound：
          # 这三个键服务的功能已被 enable_sounds = false 关掉，留着就是服务死功能的
          # 旋钮（以后开音效时 GUI 会自己把音量写进 settings.toml）。
          # 注意上面两个也是“出厂默认”而非“本机现状”：本机 settings.toml 里有自己
          # 的值且优先生效，约定见 docs/themes.md 的「Noctalia：调色板归 Nix」一节。
        };
      };

      # 壳层调色板：与 GTK / Qt / niri 装饰同源，全部取自 MacTahoe-Dark 的
      # share/themes/MacTahoe-Dark/gtk-4.0/gtk.css（括号内是该色在 CSS 里的出现次数）。
      #
      # 为什么不直接用社区方案的 ADW：它的 mSurface 恰好也是 #242424，但
      #   mOnSurfaceVariant = mOnSurface = #ffffff   → 没有文字层级
      #   mSecondary = #1b467c                        → 暗海军蓝，在 #242424 上几乎不可见
      #   mTertiary = #ffffff                         → 纯白当强调色，且与文字色重复
      #   mPrimary = #3584e4                          → GNOME 蓝，不是壳层的 #0088FF
      #   mHover = #3584e4                            → 饱和强调色当悬浮底色（文档约定是柔和提亮）
      #   mSurfaceVariant = #1e1e1e                   → 比主面更暗，层叠方向反了
      #
      # 不写 light 变体：文档规定省略时两种模式都用 dark，而桌面是纯深色。
      customPalettes.mactahoe = {
        dark = {
          mPrimary = "#0088FF"; # 主强调色 (106)
          mOnPrimary = "#FFFFFF";
          mSecondary = "#2E7CF7"; # 同族第二蓝（按下/深色态）(12)
          mOnSecondary = "#FFFFFF";
          mTertiary = "#4DACFF"; # 同族亮蓝，供渐变中段 (6)
          mOnTertiary = "#242424";
          mError = "#ED5F5D"; # 与 niri 的 urgent-color 同源 (29)
          mOnError = "#FFFFFF";
          mSurface = "#242424"; # 主面 (73)
          mOnSurface = "#DEDEDE"; # 主文字 (95)
          mSurfaceVariant = "#333333"; # 次级面：卡片 / 胶囊底 (54)
          mOnSurfaceVariant = "#AFAFAF"; # 次级文字 (13)
          # = MacTahoe 给窗口的 rgba(255,255,255,0.15) 发丝边压在 #242424 上的
          #   合成值，也就是它自家的"玻璃边缘高光"
          mOutline = "#454545";
          # 唯一插值项：MacTahoe 只提供 #242424 与 #333333 两级灰，而悬浮态必须与
          # 主面、次级面都能区分，故取两者之间
          mHover = "#3D3D3D";
          mOnHover = "#FFFFFF";
          mShadow = "#000000";

          # 终端色槽属于"工作区"一族而不是壳层。填成 Catppuccin Frappe（取值对齐
          # modules/home-manager/gui/apps/foot.nix）是为了万一将来开启 Noctalia 的
          # 终端模板时，它生成的东西与本仓库 foot/btop 的配色一致；
          # 模板目前是关的（settings.toml 里 enable_builtin_templates = false）。
          terminal = {
            background = "#303446";
            foreground = "#C6D0F5";
            cursor = "#F2D5CF";
            cursorText = "#303446";
            # 选区与 foot 同源：mauve（见 docs/themes.md 的「双层配色模型」）
            selectionBg = "#CA9EE6";
            selectionFg = "#303446";
            normal = {
              black = "#51576D";
              red = "#E78284";
              green = "#A6D189";
              yellow = "#E5C890";
              blue = "#8CAAEE";
              magenta = "#F4B8E4";
              cyan = "#81C8BE";
              white = "#B5BFE2";
            };
            bright = {
              black = "#626880";
              red = "#E78284";
              green = "#A6D189";
              yellow = "#E5C890";
              blue = "#8CAAEE";
              magenta = "#F4B8E4";
              cyan = "#81C8BE";
              white = "#A5ADCE";
            };
          };
        };
      };
    };
  };
}
