# Home Manager 配置（跨平台）
# 所有主机共享的基础配置：stateVersion、CLI 环境导入
{
  config,
  lib,
  ...
}:
let
  cfg = config.mengw.cli;
in
{
  options.mengw.cli.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 CLI/TUI 用户环境";
  };

  config = {
    home.stateVersion = "26.05";
    home.enableNixpkgsReleaseCheck = false;

    # overlay 说明：useGlobalPkgs = true（见 flake.nix 的 mkHomeManager）后，
    # HM 复用系统级 nixpkgs 实例——NUR 与自定义包（主题 / mcpp 等）由
    # modules/nixos/core 与 modules/darwin/base 在系统级统一注入，
    # 本模块不再单独维护 nixpkgs.overlays / allowUnfree。
    #
    # 历史包袱清理记录（2026-09）：此处曾有三个 overlay——NUR、fish 补全
    # 脚本路径 workaround（上游修复 home-manager#9555）、stdenv.isLinux/
    # isDarwin 弃用警告 workaround。后两者是 HM 锁 release-26.05 与
    # nixpkgs master 的 API 错位产物，HM 切回 master 后已删除，勿再引入。
  };

  # 仅导入 CLI 模块；GUI 模块由各主机按需导入
  # （WSL/server 无图形界面，desktop/laptop 通过 mkHomeManager extraModules 额外引入）
  imports = [
    ./cli
  ];
}
