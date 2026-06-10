# 常用桌面应用（Niri 和 GNOME 共用）
{ pkgs
, config
, lib
, inputs
, ...
}:

{
  environment.systemPackages = lib.subtractLists cfg.exclude (
    with pkgs;
    [
      # 常用应用
      kdePackages.ark # 解压工具
      readest # 电子书阅读
      kdePackages.okular # 通用文档阅读器
      kdePackages.kate # 轻量文本编辑
      qview # 图片查看器
      kdePackages.dolphin # 文件管理器
      mpv # 视频播放器
      snipaste # 截图工具
      freetube # YouTube 客户端
      microsoft-edge # 浏览器
      zed-editor # 代码编辑器-加速
      notepad-next # 文本编辑器
      typora # markdownb 编辑器
      obsidian # 笔记
      siyuan # 笔记
      xournalpp # PDF批注手写笔记
      zotero # 文献管理
      thunderbird # 邮件管理
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
      cc-switch # AI 管理
      cherry-studio
      baidupcs-go # 百度网盘
      # === 通讯工具 ===
      wechat # 微信
      wemeet # 腾讯会议
      # qq # qq
      discord # Discord
      telegram-desktop # Telegram
      feishu # 飞书
    ]
  );
}
