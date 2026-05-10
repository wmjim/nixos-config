# 常用桌面应用（Niri 和 GNOME 共用）
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # 常用应用
    kdePackages.dolphin # 文件管理器
    microsoft-edge      # 浏览器
    zed-editor          # 代码编辑器-加速
    vscode              # 代码编辑器
    obsidian            # 笔记工具-本地
    thunderbird         # 邮件管理

    # GTK/Qt 主题
    gtk4                      # GTK4 运行时
    fluent-gtk-theme          # 主题
    gnome-themes-extra        # 主题引擎
    whitesur-icon-theme       # 图标主题
    bibata-cursors            # 光标主题
  ];
}
