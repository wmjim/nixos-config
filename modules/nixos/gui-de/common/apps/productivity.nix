# 生产力 / 笔记 / 文献管理
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    obsidian # 笔记
    siyuan # 笔记
    zotero # 文献管理
    anki # 助记卡片
    readest # 电子书阅读
    typora # markdown 编辑器
    thunderbird # 邮件客户端
    wpsoffice-cn # wps
    xunlei-uos # bt 下载
    planify # todo 管理
  ];
}
