# Stylix 统一主题系统（NixOS 级）
# 使用 unstable 分支，提供 Gruvbox 和 Catppuccin 两种配色方案
{ lib, config, pkgs, inputs, ... }:
let
  cfg = config.mySystem.stylix;
in
{
  options.mySystem.stylix = {
    enable = lib.mkEnableOption "Stylix 统一主题系统";
    theme = lib.mkOption {
      type = lib.types.enum [ "catppuccin-mocha" "gruvbox-dark" ];
      default = "gruvbox-dark";
      description = "Stylix 配色方案：catppuccin-mocha (默认) 或 gruvbox-dark";
    };
  };

  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  config = lib.mkIf cfg.enable {
    stylix = {
      # 启用 Stylix
      enable = true;

      # 两个内置 base16 配色方案
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
      }.${cfg.theme};

      # 如若未声明 base16Scheme，Stylix 使用遗传算法根据壁纸生成一套配色方案
      # 算法生成倾向：dark(深色主题)
      polarity = "dark";
      
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
