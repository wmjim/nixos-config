# 辅助函数库
{ lib, ... }:

{
  # 为所有系统生成属性集（只保留你需要的平台）
  forAllSystems = lib.genAttrs [ "x86_64-linux" "aarch64-darwin" ];
}
