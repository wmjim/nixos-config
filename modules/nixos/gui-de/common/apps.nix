# 常用桌面应用（Niri 和 GNOME 共用）
{ pkgs, inputs, ... }:

{
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
    # 哔哩哔哩
    (bilibili.override { electron = electron_40; })
    # 欧陆英语词典（闭源 Qt5 应用，只支持 XCB 插件，需覆盖 QT_QPA_PLATFORM）
    (pkgs.writeShellScriptBin "eudic" ''
      export QT_QPA_PLATFORM=xcb
      exec ${pkgs.eudic}/bin/eudic "$@"
    '')
    folo                # 信息聚合平台
    localsend           # 跨平台文件共享
    wechat              # 微信
    qq                  # qq
    feishu              # 飞书

    # 划词和OCR翻译
    # pkgs.nur.repos.awa2333.pot-translation
  ];
}
