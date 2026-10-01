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
    # modules/nixos/core 与 modules/darwin/base 在系统级统一注入，本模块不维护
    # nixpkgs.overlays / allowUnfree：在这里抹掉 HM 与 nixpkgs 的 API 差异会
    # 把两边的版本绑定死，别再引入。
  };

  # 仅导入 CLI 模块；GUI 模块由各主机按需导入
  # （WSL/server 无图形界面，desktop/laptop 通过 mkHomeManager extraModules 额外引入）
  imports = [
    ./cli
  ];
}
