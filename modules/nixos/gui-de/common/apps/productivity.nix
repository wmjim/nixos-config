# 生产力 / 笔记 / 文献管理
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    obsidian # 笔记
    siyuan # 笔记
    zotero # 文献管理
    anki # 助记卡片
    xournalpp # PDF 批注手写笔记
    readest # 电子书阅读
    typora # markdown 编辑器
    thunderbird # 邮件客户端
    wpsoffice-cn # wps
    transmission_4 # BT 下载
  ];
}
