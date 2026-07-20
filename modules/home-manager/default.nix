# Home Manager 配置（跨平台）
# 所有主机共享的基础配置：stateVersion、overlay、CLI 环境
{ config, pkgs, lib, inputs, ... }:
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

    # NUR overlay（home-manager 独立 nixpkgs 实例需要单独添加）
    nixpkgs.overlays = [
      inputs.nur.overlays.default

      # 修复 fish 4.8.0: create_manpage_completions.py 在源码中存在但未被安装
      # 导致 bat/cargo 等包无法生成 fish 补全。上游 issue: NixOS/nixpkgs#535122
      (final: prev: {
        fish = prev.fish.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            mkdir -p $out/share/fish/tools
            cp ../share/tools/create_manpage_completions.py $out/share/fish/tools/
          '';
        });
      })
    ];
  };

  # 仅导入 CLI 模块；GUI 模块由各主机按需导入
  # （WSL/server 无图形界面，desktop/laptop 通过 mkHomeManager extraModules 额外引入）
  imports = [
    ./cli
  ];
}
