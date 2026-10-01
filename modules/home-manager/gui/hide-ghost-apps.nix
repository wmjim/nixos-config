# 隐藏没有对应二进制的"幽灵" desktop entries
#
# 来源在包本身：nixpkgs 从 gtk3 剥离了 demo 程序（gtk+3 的 bin 只有 broadwayd /
# gtk-launch / gtk-update-icon-cache），但包里的 .desktop 还在，Exec 指向不存在的
# 程序。gtk+3 由 GNOME 会话拉进系统 profile，于是 App Grid 会列出点了没反应的图标。
#
# 上游产物，包层面去不掉，只能在这里用 NoDisplay 覆盖。
# （gtk4 的同类条目曾走这里，现已从 modules/nixos/desktop/default.nix 的
# systemPackages 移除了那个多余的 gtk4 包，条目随之消失，不必再逐个隐藏。）
{ lib, config, ... }:
let
  cfg = config.mengw.gui.hide-ghost-apps;
  guiCfg = config.mengw.gui;

  ghostApps = [
    "gtk3-demo"
    "gtk3-icon-browser"
    "gtk3-widget-factory"
  ];
in
{
  options.mengw.gui.hide-ghost-apps.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "隐藏无对应二进制的幽灵 desktop entries";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    xdg.dataFile = builtins.listToAttrs (
      builtins.map (name: {
        inherit name;
        value = {
          text = ''
            [Desktop Entry]
            Type=Application
            NoDisplay=true
          '';
        };
      }) (builtins.map (x: "applications/${x}.desktop") ghostApps)
    );
  };
}
