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
      type = lib.types.enum [ "catppuccin-mocha" "gruvbox-dark" "adwaita" "claude-light" ];
      default = "claude-light";
      description = "Stylix 配色方案：claude-light (默认)、gruvbox-dark、catppuccin-mocha 或 adwaita";
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
        catppuccin-mocha = {
          base00 = "1e1e2e"; # base
          base01 = "181825"; # mantle
          base02 = "313244"; # surface0
          base03 = "45475a"; # surface1
          base04 = "585b70"; # surface2
          base05 = "cdd6f4"; # text
          base06 = "f5e0dc"; # rosewater
          base07 = "b4befe"; # lavender
          base08 = "f38ba8"; # red
          base09 = "fab387"; # peach
          base0A = "f9e2af"; # yellow
          base0B = "a6e3a1"; # green
          base0C = "94e2d5"; # teal
          base0D = "89b4fa"; # blue
          base0E = "cba6f7"; # mauve
          base0F = "f2cdcd"; # flamingo
        };
        gruvbox-dark = {
          base00 = "1d2021"; # dark bg
          base01 = "3c3836"; # dark gray
          base02 = "504945"; # medium gray
          base03 = "665c54"; # light gray
          base04 = "bdae93"; # dark fg
          base05 = "d5c4a1"; # foreground
          base06 = "ebdbb2"; # light fg
          base07 = "fbf1c7"; # brightest
          base08 = "fb4934"; # red
          base09 = "fe8019"; # orange
          base0A = "fabd2f"; # yellow
          base0B = "b8bb26"; # green
          base0C = "8ec07c"; # aqua
          base0D = "83a598"; # blue
          base0E = "d3869b"; # purple
          base0F = "d65d0e"; # brown
        };
        adwaita = {
          # Adwaita 亮色主题（Libadwaita 官方色板）
          # 背景渐变：light → dark
          base00 = "fafafb"; # window-bg
          base01 = "ebebed"; # sidebar-bg
          base02 = "deddda"; # light-3, 选中背景
          base03 = "9a9996"; # light-5, 注释/弱化
          base04 = "77767b"; # dark-1, 次要文字
          base05 = "3d3846"; # dark-3, 主前景文字
          base06 = "241f31"; # dark-4, 强调文字
          base07 = "000000"; # dark-5, 最深
          # 强调色（深色调，保证亮色背景上的对比度）
          base08 = "e01b24"; # red-3,   红：错误/变量
          base09 = "c64600"; # orange-5, 橙：数字
          base0A = "e5a50a"; # yellow-5, 黄：类名
          base0B = "26a269"; # green-5,  绿：字符串
          base0C = "007184"; # teal,     青：支持/内置
          base0D = "1a5fb4"; # blue-5,   蓝：函数
          base0E = "813d9c"; # purple-4, 紫：关键字
          base0F = "63452c"; # brown-5,  棕：废弃
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
      }.${cfg.theme};

      # 如若未声明 base16Scheme，Stylix 使用遗传算法根据壁纸生成一套配色方案
      # 算法生成倾向：adwaita、claude-light → light，其他 → dark
      polarity = if (cfg.theme == "adwaita" || cfg.theme == "claude-light") then "light" else "dark";
      
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
