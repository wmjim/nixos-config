# 桌面应用模块入口
# 导入所有应用子模块，设置 NUR overlay（pot / harmonyos-sans 等依赖）
{ inputs, ... }:

{
  imports = [ ./apps ];

  nixpkgs.overlays = [ inputs.nur.overlays.default ];
}
