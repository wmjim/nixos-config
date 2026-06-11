# cc-switch — AI 管理工具 (Tauri v2)
# 自定义 derivation 定义在 packages/cc-switch/
{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.callPackage ../../../../../packages/cc-switch { })
  ];
}
