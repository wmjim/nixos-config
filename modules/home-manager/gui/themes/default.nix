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
        name = "MacTahoe-Light";
      };
    };
  };
}
