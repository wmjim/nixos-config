# Noctalia Shell 用户级配置
{ lib, config, osConfig, inputs, ... }:
let
  cfg = config.mengw.gui.wm.noctalia;
  wmCfg = config.mengw.gui.wm;
  guiCfg = config.mengw.gui;

  # DDC/CI 亮度依赖 i2c-dev 且需外接显示器支持，仅 desktop 满足
  # （hosts/desktop/default.nix 开了 hardware.i2c.enable，laptop 未开）。
  # laptop 内屏是 eDP，走 sysfs backlight；在 laptop 上 enable_ddcutil 只会让
  # noctalia 反复跑必然失败的 ddcutil detect。
  useDdc = osConfig.networking.hostName == "desktop";
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

  config = lib.mkIf (cfg.enable && wmCfg.enable && guiCfg.enable) {
    programs.noctalia = {
      enable = true;

      # ⚠️ 这里的 settings 只是**出厂默认值**：GUI 里的改动会写进
      # ~/.local/state/noctalia/settings.toml（运行时状态），并覆盖本文件对应键。
      # 模块文档原话："these settings can still be overwritten at runtime via the
      # settings menu"。故 bar 的布局（控件列表、胶囊、透明度）与插件配置不在此
      # 维护，那部分归 GUI；本模块只负责需要在版本控制里钉死的东西：调色板。
      # 实测被运行时覆盖的键见 doc/themes.md 的"Noctalia"一节。
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
        brightness = {
          enable_ddcutil = useDdc;
          monitor = lib.mkIf useDdc { "DP-2".backend = "ddcutil"; };
        };
        audio = {
          # 不写 enable：noctalia 1.0 的配置校验把它判为 "unknown setting"
          # （noctalia config validate 实测报 audio.enable: unknown setting）
          enable_overdrive = true;
          enable_sounds = false;
          sound_volume = 0.6;
          volume_change_sound = "";
          notification_sound = "";
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
            selectionBg = "#F2D5CF";
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
