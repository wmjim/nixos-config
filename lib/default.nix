# 自定义函数库
# 提供跨模块共享的工具函数，避免重复代码
{ lib }:
{
  # 为所有支持的平台生成属性集
  # 用法: forAllSystems (system: pkgs: ...)
  forAllSystems = lib.genAttrs [
    "x86_64-linux"
    "aarch64-darwin"
  ];
}
