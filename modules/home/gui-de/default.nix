# GUI/桌面环境用户配置
{ ... }:

{
  imports = [
    ./themes
    ./apps
    ./niri
    ./fcitx5.nix
    ./vscode.nix
    ./hide-ghost-apps.nix
  ];
}
