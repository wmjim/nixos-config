# 生产力 / 笔记 / 文献管理
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.apps.productivity;
  appsCfg = config.mengw.gui.apps;
  guiCfg = config.mengw.gui;
in
{
  options.mengw.gui.apps.productivity.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用生产力应用（笔记、文献管理等）";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && guiCfg.enable) {
    home.packages = with pkgs; [
      zotero
      anki
      siyuan      # 笔记软件
      obsidian    # 笔记软件
      typora      # markdown 编辑器
      thunderbird # 邮件管理
    ];
  };
}
