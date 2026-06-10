# pot-translation 跨平台划词翻译软件
# NUR 包没有 .desktop 文件，手动创建桌面入口
{ pkgs, ... }:
let
  pot-icon = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/pot-app/pot-desktop/master/public/icon.svg";
    hash = "sha256-Fgn8kC4GhIOkzUmGre7OCW5fED5N1AU1KrXbbCh714I=";
  };
  pot-desktop = pkgs.makeDesktopItem {
    name = "pot";
    desktopName = "Pot";
    exec = "pot";
    icon = "${pot-icon}";
    comment = "划词翻译";
    categories = [ "Utility" ];
    terminal = false;
    mimeTypes = [ ];
  };
in {
  environment.systemPackages = [
    pkgs.nur.repos.awa2333.pot-translation
    pot-desktop
  ];
}
