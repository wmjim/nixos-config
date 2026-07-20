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

      # fish 4.8.0+ 不再安装 create_manpage_completions.py 到 $out，
      # 导致 home-manager generateCompletions 无法生成 man page 补全。
      # 该文件在源码中仍存在（share/tools/），此处手动拷贝到输出路径。
      #
      # 上游: nixpkgs#535122 (closed, 标记为 HM 域问题)
      # 修复: home-manager#9555 (已合并 master, 改用 status get-file)
      # TODO: 升级 home-manager 到包含 #9555 的版本后移除此 overlay
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
