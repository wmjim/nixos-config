# 隐藏 GTK4 没有对应二进制的幽灵 desktop entries
{ lib, config, ... }:
let
  cfg = config.mengw.gui.hide-ghost-apps;
  guiCfg = config.mengw.gui;

  ghostApps = [
    "org.gtk.Demo4"
    "org.gtk.gtk4.NodeEditor"
    "org.gtk.PrintEditor4"
    "org.gtk.Shaper"
    "org.gtk.WidgetFactory4"
  ];
in
{
  options.mengw.gui.hide-ghost-apps.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "隐藏 GTK4 幽灵 desktop entries";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    xdg.dataFile = builtins.listToAttrs (builtins.map (name: {
      inherit name;
      value = {
        text = ''
          [Desktop Entry]
          Type=Application
          NoDisplay=true
        '';
      };
    }) (builtins.map (x: "applications/${x}.desktop") ghostApps));
  };
}
