# 隐藏 GTK4 没有对应二进制的幽灵 desktop entries
# 这些 .desktop 文件被 gtk4 包安装，但可执行文件在未安装的 gtk4-demo 包中
{ ... }:

let
  ghostApps = [
    "org.gtk.Demo4"
    "org.gtk.gtk4.NodeEditor"
    "org.gtk.PrintEditor4"
    "org.gtk.Shaper"           # 显示为 "Icon Editor"
    "org.gtk.WidgetFactory4"
  ];
in
{
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
}
