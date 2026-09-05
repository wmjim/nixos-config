# VSCode 编辑器
# 扩展策略：不再用 nix 管理扩展（programs.vscode.profiles.extensions）。
#
# 背景：之前 mutableExtensionsDir = true，与 VSCode 自持的
# extensions.json/.obsolete 索引相互打架 —— flake update 重建后扩展 store path
# 变更、索引刷新时机又受"VSCode 是否在运行"影响，导致 nix 管理的插件反复丢失。
# 现改由 VSCode 内置 Settings Sync（登录账号云同步）管理扩展，此处仅安装 code 本体。
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.vscode;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.vscode.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 VSCode 编辑器";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    programs.vscode.enable = true;
  };
}
