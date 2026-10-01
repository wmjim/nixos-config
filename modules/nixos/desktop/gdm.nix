# GDM 登录管理器
{ lib, config, ... }:
let
  cfg = config.mySystem.desktop;

  # 登录界面背景：greeter 从 gdm 用户的 dconf profile 读
  # org.gnome.desktop.background。这里取 store 路径（wallpapers 首项）而不是
  # ~/Pictures 里那份部署副本：greeter 的 systemd 单元受限、且 store 路径
  # 世界可读、不可变。深色变体一并设：greeter 恒为深色，GNOME 42+ 在深色
  # 模式下读 picture-uri-dark 而不是 picture-uri。
  # 界面本身的换肤（gnome-shell-theme.gresource）见 gnome/default.nix。
  greeterDatabases = lib.optionals (cfg.wallpapers != [ ]) [
    {
      settings."org/gnome/desktop/background" = {
        picture-uri = "file://${lib.head cfg.wallpapers}";
        picture-uri-dark = "file://${lib.head cfg.wallpapers}";
      };
    }
  ];
in
{
  config = lib.mkIf cfg.enable {
    # 启用 GDM 作为显示管理器
    services.displayManager.gdm.enable = true;

    # 登录界面与桌面会话共用同一张壁纸，见 docs/themes.md 的壁纸一节
    programs.dconf.profiles.gdm.databases = greeterDatabases;
  };
}
