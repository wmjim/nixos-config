# 生产力 / 笔记 / 文献管理
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.apps.productivity;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.productivity.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用生产力应用（笔记、文献管理等）";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    home.packages = with pkgs; [
      zotero
      anki
      xmind
      siyuan # 笔记软件
      obsidian # 笔记软件
      typora # markdown 编辑器
      thunderbird # 邮件管理
    ];

    # 思源笔记是 Electron 应用，其 package.json 的 desktopName 为 "org.b3log.siyuan"，
    # Electron 启动时会自动调用 app.setDesktopName()，该值经 Wayland xdg_toplevel.set_app_id
    # 由 mutter 写入窗口的 wm_class。而 nixpkgs 包提供的 siyuan.desktop 未设置 StartupWMClass，
    # 导致 GNOME Shell 匹配不到应用，Dash to Panel 图标回退为 application-x-executable（齿轮图标）。
    # 通过 StartupWMClass 把窗口 app_id 关联回 siyuan.desktop，即可命中 Icon=siyuan。
    # 注意：生效需重启 GNOME Shell（Alt+F2 → r）或重新登录。
    xdg.desktopEntries.siyuan = {
      name = "SiYuan";
      comment = "Refactor your thinking";
      exec = "siyuan %U";
      icon = "siyuan";
      categories = [ "Utility" ];
      type = "Application";
      settings.StartupWMClass = "org.b3log.siyuan";
    };
  };
}
