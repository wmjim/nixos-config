# Fcitx5 用户级配置
{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.gui.fcitx5;
  guiCfg = config.mengw.gui;

  rimeDir = "${config.home.homeDirectory}/.local/share/fcitx5/rime";

  # 记录上次部署时 rime 数据源指纹，用于判断是否需要清理构建缓存。
  # 放在 rime 目录之外，避免被 rime 当作自身数据文件处理。
  stampFile = "${config.home.homeDirectory}/.local/share/fcitx5/.rime-data-key";

  # rime 按 mtime 判断构建缓存是否失效，而 nix store 内文件 mtime 恒为 0，
  # 因此数据包路径变化时 rime 会重建词典却沿用旧 schema，导致输入法静默失效
  # （进程在、schema 在，却出不来候选词）。这里以数据源路径作为指纹显式失效。
  #
  # 指纹只参与字符串比较，故丢弃字符串上下文，避免把基线包拖进运行时闭包
  # （否则每次 switch 都会为 fcitx5-rime / rime-data 多下载约 16MB）。
  # 路径即使被 GC，只做比较也依然有效。
  pathKey = p: builtins.unsafeDiscardStringContext (toString p);
  rimeDataKey = lib.concatStringsSep ":" [
    (pathKey pkgs.rime-wanxiang)
    (pathKey pkgs.fcitx5-rime)
  ];
in
{
  options.mengw.gui.fcitx5.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Fcitx5 用户级配置（Rime）";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    # 经典界面（候选词窗口）主题。该文件由 fcitx5 自行生成，但内容全是用户偏好、
    # 无易变状态，故整体托管；fcitx5 GUI 里的改动会在下次 switch 时被覆盖回此处。
    #
    # UseDarkTheme 的语义是"跟随系统"而非"强制深色"：fcitx5 通过 XDG Desktop
    # Portal 监听 org.freedesktop.appearance 的 color-scheme，为 1（prefer-dark）
    # 时才使用 DarkTheme。故本项**依赖 themes 模块的 gtk.colorScheme = "dark"**：
    #
    #   gtk.colorScheme=dark → dconf org.gnome.desktop.interface color-scheme
    #                        → xdg-desktop-portal-gnome/gtk 上报 color-scheme=1
    #                        → fcitx5 切到 DarkTheme
    #
    # 若只改此处而不改 gtk.colorScheme，候选词窗会停在下面的浅色 Theme。
    # 主题名取自 fcitx5 自带主题包（default / mellow-* / kwinblur-mellow-*），
    # 无深色变体时就只能换主题名而不能靠 UseDarkTheme 变深。
    xdg.configFile."fcitx5/conf/classicui.conf".text = ''
      # 垂直候选列表
      Vertical Candidate List=False
      # 使用鼠标滚轮翻页
      WheelForPaging=True
      # 字体：与 GTK 界面字体一致（12pt）
      Font="HarmonyOS Sans SC 12"
      # 菜单字体
      MenuFont="HarmonyOS Sans SC Medium Medium 12"
      # 托盘字体
      TrayFont="HarmonyOS Sans SC Medium Medium 12"
      # 托盘标签轮廓颜色
      TrayOutlineColor=#000000
      # 托盘标签文本颜色
      TrayTextColor=#ffffff
      # 优先使用文字图标
      PreferTextIcon=False
      # 在图标中显示布局名称
      ShowLayoutNameInIcon=True
      # 使用输入法的语言来显示文字
      UseInputMethodLanguageToDisplayText=True
      # 主题（浅色模式）
      Theme=mellow-youlan
      # 深色主题
      DarkTheme=mellow-youlan-dark
      # 跟随系统浅色/深色设置
      UseDarkTheme=True
      # 当被主题和桌面支持时使用系统的重点色
      UseAccentColor=True
      # 在 X11 上针对不同屏幕使用单独的 DPI
      PerScreenDPI=False
      # 固定 Wayland 的字体 DPI
      ForceWaylandDPI=0
      # 在 Wayland 下启用分数缩放
      EnableFractionalScale=True
    '';

    home.file.".local/share/fcitx5/rime/default.custom.yaml".text = ''
      patch:
        __include: wanxiang_suggested_default:/
        __patch:
          menu/page_size: 7
    '';

    # 只在数据源指纹变化时才清理，避免每次 switch 都触发全量重建。
    # 仅删除 build/（纯派生产物）；用户词典 *.userdb、*.gram、sync/ 均保留。
    home.activation.rimeBuildCacheInvalidate =
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "${rimeDir}" ]; then
          verboseEcho "rime 数据目录不存在，跳过构建缓存清理: ${rimeDir}"
        elif [ "$(cat "${stampFile}" 2>/dev/null || true)" != "${rimeDataKey}" ]; then
          verboseEcho "rime 数据源已变化，清理构建缓存（保留用户词典）"
          $DRY_RUN_CMD rm -rf "${rimeDir}/build"
          $DRY_RUN_CMD mkdir -p "$(dirname "${stampFile}")"
          $DRY_RUN_CMD printf '%s\n' "${rimeDataKey}" > "${stampFile}"
        else
          verboseEcho "rime 数据源未变化，保留构建缓存"
        fi
      '';
  };
}
