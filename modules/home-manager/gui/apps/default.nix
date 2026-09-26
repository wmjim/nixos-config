# GUI 应用聚合模块
# 所有 GUI 应用统一由 Home Manager 管理（home.packages）
# 门控：目录导入即生效（mengw.gui.enable 控制整个 GUI 层），无中间层开关；
# 单独关闭某个应用用该叶子自己的 enable 选项。
{ ... }:
{
  imports = [
    ./foot.nix
    ./browsers.nix
    ./communication.nix
    ./media.nix
    ./productivity.nix
    ./steam.nix
    ./development.nix
    ./embedded.nix
    ./utilities.nix
    ./pot.nix
  ];
}
