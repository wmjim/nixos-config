# 桌面应用模块入口
# 导入所有应用子模块，设置 NUR overlay（pot / harmonyos-sans 等依赖）
# NUR overlay 必须无条件设置 — 它是包源基础设施，不是功能开关
{ inputs, ... }:
{
  imports = [ ./apps ];

  nixpkgs.overlays = [ inputs.nur.overlays.default ];
}
