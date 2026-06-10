# 常用桌面应用（Niri 和 GNOME 共用）
{ pkgs
, config
, lib
, inputs
, ...
}:

{
  environment.systemPackages = with pkgs; [
    # 常用应用
    kdePackages.ark # 解压工具
    readest # 电子书阅读
    kdePackages.okular # 通用文档阅读器
    gnome-text-editor # 轻量文本编辑
    qview # 图片查看器
    nautilus # 文件管理器
    mpv # 视频播放器
    snipaste # 截图工具
    freetube # YouTube 客户端
    microsoft-edge # 浏览器
    zed-editor # 代码编辑器
    typora # markdownb 编辑器
    obsidian # 笔记
    siyuan # 笔记
    xournalpp # PDF批注手写笔记
    zotero # 文献管理
    # thunderbird 所有文件重定向到 ~/files/apps/thunderbird
    # 通过覆盖 $HOME 阻止在主目录生成 ~/thunderbird、~/.thunderbird
    (pkgs.writeShellScriptBin "thunderbird" ''
      TH_DIR="$HOME/files/apps/thunderbird"
      mkdir -p "$TH_DIR"
      exec env HOME="$TH_DIR" ${pkgs.thunderbird}/bin/thunderbird --profile "$HOME/files/apps/thunderbird" "$@"
    '')
    obs-studio # 录屏
    anki # 助记卡片
    picgo # 图床管理
    logisim-evolution # 数字电路设计
    bilibili # 哔哩哔哩
    # 欧路英语词典（闭源 Qt5 应用，只支持 XCB 插件，强制覆盖 QT_QPA_PLATFORM）
    (pkgs.writeShellScriptBin "eudic" ''
      export QT_QPA_PLATFORM=xcb
      exec ${pkgs.eudic}/bin/eudic "$@"
    '')
    folo # 信息聚合平台
    localsend # 跨平台文件共享
    # cc-switch 所有文件重定向到 ~/files/apps/cc-switch
    (pkgs.writeShellScriptBin "cc-switch" ''
      CC_DIR="$HOME/files/apps/cc-switch"
      mkdir -p "$CC_DIR"
      exec env HOME="$CC_DIR" ${pkgs.cc-switch}/bin/cc-switch "$@"
    '')
    cherry-studio
    baidupcs-go # 百度网盘
    # === 通讯工具 ===
    # 微信所有文件重定向到 ~/files/apps/wechat
    (pkgs.writeShellScriptBin "wechat" ''
      WECHAT_DIR="$HOME/files/apps/wechat"
      mkdir -p "$WECHAT_DIR"
      exec env HOME="$WECHAT_DIR" ${pkgs.wechat}/bin/wechat "$@"
    '')
    wemeet # 腾讯会议
    # qq # qq
    discord # Discord
    telegram-desktop # Telegram
    feishu # 飞书
  ];
}
