# Stylix 统一主题系统（NixOS 级）
# 使用 unstable 分支，提供 Gruvbox、Catppuccin、Adwaita 四种配色方案
{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.mySystem.stylix;
in
{
  options.mySystem.stylix = {
    enable = lib.mkEnableOption "Stylix 统一主题系统";
    theme = lib.mkOption {
      type = lib.types.enum [ "aurora-dark" "claude-light" "macos-light" "macos-dark" ];
      default = "macos-light";
      description = "Stylix 配色方案：aurora-dark、claude-light、macos-light、macos-dark";
    };
  };

  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  config = lib.mkIf cfg.enable {
    stylix = {
      # 启用 Stylix
      enable = true;

      # 内置 base16 配色方案
      base16Scheme = {
        aurora-dark = {
          base00 = "11141b"; # background-主背景，窗口/终端/编辑器默认背景
          base01 = "181c24"; # mantle-次背景，侧边栏/状态栏/行号区域
          base02 = "252b36"; # surface0-选中背景，文本选中高亮，搜索匹配高亮
          base03 = "353d4a"; # surface1-注释文字，注释/行号/不可见字符
          base04 = "566171"; # surface2-次要文字，状态栏文字/折叠标记/不活跃标签

          base05 = "e4e9f2"; # text-主文字，默认前景色，普通代码/正文
          base06 = "f3f6fb"; # light text-强调文字，粗体、高调文字
          base07 = "ffffff"; # brightest-最亮色

          base08 = "f06c82"; # red
          base09 = "f2a86b"; # orange
          base0A = "e7d97d"; # yellow
          base0B = "8fd49b"; # green
          base0C = "7ed7d3"; # cyan
          base0D = "76b7ff"; # blue
          base0E = "b793ff"; # purple
          base0F = "d98fb3"; # pink
        };

        claude-light = {
          # Claude 官网亮色主题（暖调奶油色板）
          # 背景渐变：暖奶油白 → 深棕
          base00 = "faf9f5"; # 主背景：暖调奶油白
          base01 = "f3f0ea"; # 侧边栏/状态栏背景
          base02 = "e8e5dd"; # 选中背景（暖灰）
          base03 = "a8a39c"; # 注释/弱化文字
          base04 = "7a746e"; # 次要文字（暖灰）
          base05 = "3d3832"; # 主前景文字（暖黑）
          base06 = "211d18"; # 强调文字
          base07 = "0f0c09"; # 最深文字
          # 强调色：暖色调为主，Claude 品牌橙贯穿其中
          base08 = "dc2626"; # red-600    红：错误/变量
          base09 = "d97706"; # amber-600  橙：Claude 品牌色/数字
          base0A = "b45309"; # amber-700  深橙：类名
          base0B = "059669"; # emerald-600 绿：字符串
          base0C = "0d9488"; # teal-600    青：内置/支持
          base0D = "4f46e5"; # indigo-600  蓝：函数
          base0E = "7c3aed"; # violet-600  紫：关键字
          base0F = "92400e"; # amber-800   棕：废弃
        };

        macos-light = {
          base00 = "ffffff"; # background-窗口背景
          base01 = "f5f5f7"; # sidebar/toolbar
          base02 = "e8e8ed"; # selection background
          base03 = "8e8e93"; # comments, secondary labels
          base04 = "6e6e73"; # tertiary text

          base05 = "1d1d1f"; # primary text
          base06 = "111113"; # emphasized text
          base07 = "000000"; # strongest text

          base08 = "ff3b30"; # red
          base09 = "ff9500"; # orange
          base0A = "ffd60a"; # yellow
          base0B = "34c759"; # green
          base0C = "64d2ff"; # cyan
          base0D = "007aff"; # blue (Accent Blue)
          base0E = "af52de"; # purple
          base0F = "ff2d55"; # pink
        };

        # macos-dark = {
        #   base00 = "1e1e1e"; # background
        #   base01 = "2a2a2c"; # sidebar/toolbar
        #   base02 = "3a3a3c"; # selection
        #   base03 = "8e8e93"; # comments
        #   base04 = "aeaeb2"; # secondary text

        #   base05 = "f2f2f7"; # primary text
        #   base06 = "ffffff"; # emphasized
        #   base07 = "ffffff"; # brightest

        #   base08 = "ff453a"; # red
        #   base09 = "ff9f0a"; # orange
        #   base0A = "ffd60a"; # yellow
        #   base0B = "30d158"; # green
        #   base0C = "64d2ff"; # cyan
        #   base0D = "0a84ff"; # blue
        #   base0E = "bf5af2"; # purple
        #   base0F = "ff375f"; # pink
        # };
          macos-dark = {
            base00 = "1f1f24";
            base01 = "28282e";
            base02 = "36363d";
            base03 = "7d7d86";
            base04 = "a0a0aa";

            base05 = "f2f2f7";
            base06 = "fafafa";
            base07 = "ffffff";

            base08 = "ff6961";
            base09 = "ff9f43";
            base0A = "ffd866";
            base0B = "63d471";
            base0C = "76e3ea";
            base0D = "4da3ff";
            base0E = "c792ea";
            base0F = "ff79c6";
          };
      }.${cfg.theme};

      # 如若未声明 base16Scheme，Stylix 使用遗传算法根据壁纸生成一套配色方案
      # 算法生成倾向：macos-dark → dark，claude-light → light
      polarity = if (cfg.theme == "macos-dark") then "dark" else "light";
      
      # 默认字体组合
      fonts = {
        # 衬线字体：Source Serif Pro
        serif = {
          package = pkgs.source-serif-pro;
          name = "Source Serif Pro";
        };
        # 无衬线字体：HarmonyOS Sans SC
        sansSerif = {
          package = pkgs.nur.repos.guanran928.harmonyos-sans;
          name = "HarmonyOS Sans SC Medium";
        };
        # 等宽字体：Maple Mono Normal NL NF
        monospace = {
          package = pkgs.maple-mono.NormalNL-NF-CN-unhinted;
          name = "Maple Mono Normal NL NF CN Medium";
        };
        # emoji字体：Noto Color Emoji
        emoji = {
          package = pkgs.noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };
        # 字体大小
        sizes = {
          desktop = 12;
          applications = 12;
          popups = 10;
          terminal = 12;
        };
      };

      # 图标主题
      icons = {
        enable = true;
        package = pkgs.papirus-icon-theme;
        dark = "Papirus-Dark";
        light = "Papirus-Light";
      };

      # 光标主题
      cursor = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };

      

      # 禁用版本检查（Stylix unstable 与 HM release-26.05 不匹配）
      enableReleaseChecks = false;

      # Qt: 强制使用 qtct（而非 GNOME 自动检测值），Stylix 通过 Kvantum 管理 Qt 主题
      targets.qt.platform = lib.mkForce "qtct";
    };

    # 解决 GNOME 的 QT_QPA_PLATFORMTHEME=gnome 与 Stylix 的 qt5ct 冲突
    environment.variables.QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";
    environment.variables.QT_QPA_PLATFORMTHEME_QT6 = lib.mkForce "qt6ct";
    # 确保所有 Qt 应用使用 Kvantum 样式（覆盖 qtct 可能未覆盖的场景）
    environment.variables.QT_STYLE_OVERRIDE = "kvantum";

    # HM 层：禁用版本检查警告（NixOS 层的 enableReleaseChecks 不会自动同步）
    home-manager.sharedModules = lib.mkIf (config ? home-manager) [
      { stylix.enableReleaseChecks = false; }
    ];
  };
}
