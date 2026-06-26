# 生产力 / 笔记 / 文献管理
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.desktop.common.apps.productivity;
  appsCfg = config.mengw.desktop.common.apps;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.apps.productivity.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用生产力应用（笔记、文献管理等）";
  };

  config = lib.mkIf (cfg.enable && appsCfg.enable && commonCfg.enable && desktopCfg.enable) {
    environment.systemPackages = with pkgs; [
      obsidian # 笔记
      siyuan # 笔记
      zotero # 文献管理
      anki # 助记卡片
      readest # 电子书阅读
      typora # markdown 编辑器
      thunderbird # 邮件客户端
      xunlei-uos # bt 下载
      planify # todo 管理
    ];
  };
}
