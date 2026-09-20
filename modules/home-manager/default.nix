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

      # fish 4.8.0+ 的构建系统不再安装 create_manpage_completions.py 到 $out，
      # 导致 home-manager generateCompletions 无法生成 man page 补全。
      # 该文件在源码中仍存在（share/tools/），此处手动拷贝到输出路径。
      #
      # 上游: nixpkgs#535122 (closed, 判定为 HM 域问题, nixpkgs 端不修)
      # 修复: home-manager#9555 (改用 `status get-file` 从 fish 自身提取脚本)
      #   - 2026-06-25 合并进 master, 但**未回移 release-26.05**;
      #   - 本 flake 锁定 release-26.05, 其 fish.nix 仍引用 $out 硬路径,
      #     故该 overlay 目前必需, 待 HM 锁定切换到含 #9555 的分支后移除。
      # 复核记录: 2026-09-16 确认仍未回移 (compare diverged, behind_by=40)
      (final: prev: {
        fish = prev.fish.overrideAttrs (old: {
          postInstall = (old.postInstall or "") + ''
            mkdir -p $out/share/fish/tools
            cp ../share/tools/create_manpage_completions.py $out/share/fish/tools/
          '';
        });
      })

      # nixpkgs master 于 2026-05-09 弃用 stdenv.isLinux / isDarwin 等属性
      # （pkgs/stdenv/generic/default.nix 里挂 lib.warn，改为 stdenv.hostPlatform.is*），
      # 而 HM release-26.05 仍在两处读旧属性：
      #   - modules/systemd.nix  systemd.user.enable 默认值 → 每次求值警告 isLinux
      #   - modules/lib/darwin.nix  assertInterval → 每次求值警告 isDarwin
      # 每个主机因此打印 2 条 evaluation warning（nix flake check 共 4 组）。
      # 上游 master 已改用 hostPlatform.is*，但同样未回移 release-26.05。
      # 这里把这两个属性按原值重新绑定，去掉 lib.warn 包装（值不变，不影响任何构建结果）。
      # 复核记录: 2026-09-20 确认 master 已修、release-26.05 未回移；
      # 待 HM 锁定切换到 master（或含修复的分支）后删除本 overlay。
      (final: prev: {
        stdenv = prev.stdenv // {
          isLinux = prev.stdenv.hostPlatform.isLinux;
          isDarwin = prev.stdenv.hostPlatform.isDarwin;
        };
      })

      # 自打包主题（nixpkgs 未收录）：MacTahoe GTK / 图标主题 / Kvantum(Qt) 主题
      (final: prev: {
        mactahoe-gtk-theme = prev.callPackage ../../pkgs/mactahoe-gtk-theme { };
        mactahoe-icon-theme = prev.callPackage ../../pkgs/mactahoe-icon-theme { };
        mactahoe-kvantum = prev.callPackage ../../pkgs/mactahoe-kvantum { };
      })
    ];
  };

  # 仅导入 CLI 模块；GUI 模块由各主机按需导入
  # （WSL/server 无图形界面，desktop/laptop 通过 mkHomeManager extraModules 额外引入）
  imports = [
    ./cli
  ];
}
