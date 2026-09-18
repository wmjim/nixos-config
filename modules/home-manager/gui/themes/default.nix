# Qt/GTK 主题配置
{ lib, config, pkgs, osConfig, ... }:
let
  cfg = config.mengw.gui.themes;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.themes.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Qt/GTK 主题配置";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    # 全部深色：niri / Noctalia / foot / Neovim 均为深色，GTK/Qt 侧若停留在
    # 浅色，文件对话框、微信、GNOME 设置会以白底浮在深色桌面上。
    # MacTahoe 的 Dark 变体是中性灰（#242424 / #333333）+ 单一强调色 #0088FF。
    gtk = {
      enable = true;
      theme = {
        package = pkgs.mactahoe-gtk-theme;
        name = "MacTahoe-Dark";
      };
      iconTheme = {
        package = pkgs.mactahoe-icon-theme;
        # 图标主题变体后缀是小写 -dark（区别于 GTK 主题的 MacTahoe-Dark）
        name = "MacTahoe-dark";
      };
      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Classic";
        size = 24;
      };
      font = {
        name = "HarmonyOS Sans SC";
        size = 12;
      };

      # GTK4/libadwaita 不认 gtk-theme-name，只认 color-scheme：
      # gtk3 侧会写 dconf 的 org.gnome.desktop.interface color-scheme=prefer-dark，
      # gtk4 侧会写 settings.ini 的 gtk-interface-color-scheme=2。
      # 不设则 libadwaita 按 "default"（浅色）渲染，且 GNOME 系应用不跟随桌面。
      colorScheme = "dark";

      # HM 26.05 起 gtk.gtk4.theme 的默认值改为 null
      # （mkStateVersionOptionDefault，stateVersion>=26.05 时不报弃用警告），
      # 而 ~/.config/gtk-4.0/gtk.css 仅在 gtk4.theme.package != null 时才生成。
      # 不显式设置 → GTK4 应用完全拿不到 MacTahoe，退回原生 Adwaita。
      # 其余 gtk4 子选项（iconTheme/cursorTheme/font）默认继承顶层，无需重复。
      gtk4.theme = {
        package = pkgs.mactahoe-gtk-theme;
        name = "MacTahoe-Dark";
      };
    };

    # XWayland 应用（Steam 等）的光标查找路径是 ~/.local/share/icons，
    # gtk.cursorTheme 只写 gsettings、不落地主题文件到该路径，
    # 导致 libXcursor（xwayland-satellite）加载不到 Bibata、回退默认光标。
    # 这里将主题目录软链到搜索路径上（recursive=false 即目录软链）。
    xdg.dataFile."icons/Bibata-Modern-Classic" = {
      source = "${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic";
      recursive = false;
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style = {
        # HM 依 style.name 自动挑选 adwaita-qt + adwaita-qt6 并设
        # QT_STYLE_OVERRIDE=adwaita-dark，无需手写 package。
        name = "adwaita-dark";
      };
    };

    # GNOME Shell 换肤：启用 user-theme 扩展并指向 MacTahoe 主题
    # enabled-extensions 为整数组写入，故须列出全部已装扩展的 UUID，
    # 否则会覆盖用户已手动启用的扩展。
    #
    # UUID 不再硬编码：安装列表在 NixOS 侧 mySystem.desktop.gnome.extensions
    # 单一维护，此处经 osConfig 取回各包的 extensionUuid 派生启用列表，
    # 避免"装了没启用 / 启用但没装"的静默脱节。
    # osConfig 仅在 home-manager 作为 NixOS 模块集成时可用；gui 模块只在
    # NixOS 桌面主机导入（见 flake.nix），macOS 不加载本模块，故必然存在。
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = map (e: e.extensionUuid)
          (osConfig.mySystem.desktop.gnome.extensions or [ ]);
      };
      "org/gnome/shell/extensions/user-theme" = {
        name = "MacTahoe-Dark";
      };
    };
  };
}
