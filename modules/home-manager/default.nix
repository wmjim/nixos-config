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

  options.mengw.appearance.switchTargets = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          live = lib.mkOption {
            type = lib.types.str;
            description = "应用真正读的那个文件，相对 $HOME（如 .config/gtk-4.0/settings.ini）";
          };
          dark = lib.mkOption {
            type = lib.types.str;
            description = "暗色变体，相对 $HOME（如 theme-variants/gtk-3.0/dark.ini）";
          };
          light = lib.mkOption {
            type = lib.types.str;
            description = "亮色变体，相对 $HOME";
          };
        };
      }
    );
    default = [ ];
    description = ''
      亮/暗切换时要翻的软链。真源是 Noctalia 的 theme mode，执行者是 gui/themes/variants.nix
      里的 theme-apply：它只做「live 指到当前模式的变体」这件事，各层（GTK/Qt/niri、
      btop…）把自己的两个变体生成到 store 并在这里登记。
      登记者自己负责让 live 文件首次存在（HM 初始值 = 暗色）；rebuild 会把 live 还原成
      暗色，登录时的 theme-apply 再按 Noctalia 的 mode 纠正，不需要额外的状态文件。
    '';
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
