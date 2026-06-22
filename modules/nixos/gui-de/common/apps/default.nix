# GUI 应用聚合模块
# 按功能分类导入子模块，便于维护和查找
{ ... }:

{
  imports = [
    # 应用包装器（复杂配置）
    ./pot.nix

    # 按功能分类的应用集合
    ./productivity.nix
    ./media.nix
    ./communication.nix
    ./browsers.nix
    ./development.nix
    ./utilities.nix
    ./distrobox.nix
  ];
}
