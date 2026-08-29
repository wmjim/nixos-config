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
  };
}
