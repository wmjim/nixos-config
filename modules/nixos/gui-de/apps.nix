# 常用桌面应用（Niri 和 GNOME 共用）
{ pkgs, inputs, ... }:

{
  # NUR overlay (需要单独添加)
  nixpkgs.overlays = [ inputs.nur.overlays.default ];

  environment.systemPackages = with pkgs; [
    # 常用应用
    kdePackages.dolphin # 文件管理器
    microsoft-edge      # 浏览器
    zed-editor          # 代码编辑器-加速
    vscode              # 代码编辑器
    notepad-next        # 文本编辑器
    typora              # markdownb 编辑器
    obsidian            # 笔记
    siyuan              # 笔记
    zotero              # 文献管理
    thunderbird         # 邮件管理
    obs-studio          # 录屏
    anki                # 助记卡片
    picgo               # 图床管理
    bilibili            # 哔哩哔哩
    eudic               # 欧陆英语词典
    folo                # 信息聚合平台
    localsend           # 跨平台文件共享
    wechat              # 微信
    qq                  # qq
    feishu              # 飞书

    # 划词和OCR翻译
    pkgs.nur.repos.awa2333.pot-translation

    # GTK/Qt 主题
    gtk4                         # GTK4 运行时
    qt6Packages.qt6ct           # Qt6 主题配置工具
    libsForQt5.qt5ct            # Qt5 主题配置工具
    qt6Packages.qtstyleplugin-kvantum   # Kvantum 主题引擎 Qt6
    libsForQt5.qtstyleplugin-kvantum    # Kvantum 主题引擎 Qt5
    # orchis-theme              # 主题1
    adapta-kde-theme             # Adapta KDE 主题（Kvantum + Aurorae + 颜色方案）
    adapta-gtk-theme             # Adapta GTK 主题（GTK 3/4 应用）
    gnome-themes-extra        # 主题引擎
    whitesur-icon-theme       # 图标主题
    bibata-cursors            # 光标主题
  ];
}
