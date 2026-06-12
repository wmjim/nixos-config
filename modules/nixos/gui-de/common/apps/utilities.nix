# 系统工具 / 实用程序
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ddcutil # 显示器亮度调节
    kdePackages.ark # 解压工具
    kdePackages.okular # 通用文档阅读器
    gnome-text-editor # 轻量文本编辑
    qview # 图片查看器
    nautilus # 文件管理器
    logisim-evolution # 数字电路设计
    folo # 信息聚合平台
    localsend # 跨平台文件共享
    cc-switch # AI 管理工具
    cherry-studio
    baidupcs-go # 百度网盘
  ];
}
