# Qt/GTK 主题配置
{ lib, config, pkgs, ... }:
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
    gtk = {
      enable = true;
      theme = {
        package = pkgs.mactahoe-gtk-theme;
        name = "MacTahoe-Light";
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
    };

    qt = {
      enable = true;
      platformTheme.name = "adwaita";
      style = {
        package = pkgs.adwaita-qt;
        name = "adwaita";
      };
    };

    # GNOME Shell 换肤：启用 user-theme 扩展并指向 MacTahoe 主题
    # enabled-extensions 为整数组写入，故列出全部已装扩展的 UUID，
    # 避免覆盖用户已手动启用的扩展（UUID 从各扩展包 metadata 逐包核实）
    dconf.settings = {
      "org/gnome/shell" = {
        enabled-extensions = [
          "blur-my-shell@aunetx"
          "just-perfection-desktop@just-perfection"
          "arcmenu@arcmenu.com"
          "dash-to-panel@jderose9.github.com"
          "appindicatorsupport@rgcjonas.gmail.com"
          "kimpanel@kde.org"
          "clipboard-indicator@tudmotu.com"
          "compiz-alike-magic-lamp-effect@hermes83.github.com"
          "CoverflowAltTab@palatis.blogspot.com"
          "tilingshell@ferrarodomenico.com"
          "rounded-window-corners@fxgn"
          "drive-menu@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
        ];
      };
      "org/gnome/shell/extensions/user-theme" = {
        name = "MacTahoe-Light";
      };
    };

    # libadwaita（GTK4）应用换肤：GNOME 43+ 原生应用不读取 gtk-theme-name，
    # 只能通过用户样式表 ~/.config/gtk-4.0/gtk.css 覆盖。软链主题包内编译好的
    # gtk-4.0 目录文件（浅色 gtk.css + 深色 gtk-dark.css 自动跟随应用配色）。
    # 仅逐个文件软链，保留 gtk-4.0 目录中已有的 servers / settings.ini。
    xdg.configFile = {
      "gtk-4.0/gtk.css".source = "${pkgs.mactahoe-gtk-theme}/share/themes/MacTahoe-Light/gtk-4.0/gtk.css";
      # 主题包内 gtk-dark.css 是软链到 MacTahoe-Dark 的深色样式，浅深两套都覆盖
      "gtk-4.0/gtk-dark.css".source = "${pkgs.mactahoe-gtk-theme}/share/themes/MacTahoe-Dark/gtk-4.0/gtk-dark.css";
      # gtk.css 以相对路径引用 assets/windows-assets，需与之同目录；
      # 目录软链（recursive=false）避免每次激活复制 100+ 个资源文件
      "gtk-4.0/assets" = {
        source = "${pkgs.mactahoe-gtk-theme}/share/themes/MacTahoe-Light/gtk-4.0/assets";
        recursive = false;
      };
      "gtk-4.0/windows-assets" = {
        source = "${pkgs.mactahoe-gtk-theme}/share/themes/MacTahoe-Light/gtk-4.0/windows-assets";
        recursive = false;
      };
    };
  };
}
