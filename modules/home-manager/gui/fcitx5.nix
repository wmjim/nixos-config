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

  # 候选词窗主题，取自上游 catppuccin-fcitx5 的 Frappe + mauve 变体。
  # 归到"工作区"一侧而不是壳层：候选词窗是跟随文本光标出现的打字层浮层，
  # 与它同屏的总是终端/编辑器/浏览器，而那些都是 Catppuccin Frappe；
  # mauve 又是 Catppuccin 的默认强调色。
  #
  # 上游为每个变体都带了一对圆角 SVG（39x39，rx=8，填充色随变体烘焦），
  # 但 theme.conf 里把 `Image=` 两行注释掉了（默认为直角）。而桌面其余部分的
  # 圆角阶梓是 12px（窗口）/ 8px（popover、菜单、标签指示器），候选词窗又是
  # 全屏出现频率最高的浮层，留直角会显得突兀，故用 runCommand 就地打开这两行。
  # 不 fork 主题内容：只改这两行，Frappe 调色板仍随 nixpkgs 更新。
  theme = pkgs.runCommand "fcitx5-theme-catppuccin-frappe-mauve" { } ''
    themeDir=$out/share/fcitx5/themes/catppuccin-frappe-mauve
    mkdir -p "$themeDir"
    cp -r ${pkgs.catppuccin-fcitx5}/share/fcitx5/themes/catppuccin-frappe-mauve/. "$themeDir/"
    chmod -R u+w "$themeDir"
    substituteInPlace "$themeDir/theme.conf" \
      --replace-fail '# Image=panel.svg' 'Image=panel.svg' \
      --replace-fail '# Image=highlight.svg' 'Image=highlight.svg'
  '';
in
{
  options.mengw.gui.fcitx5.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Fcitx5 用户级配置（Rime）";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    home.packages = [ theme ];

    # 经典界面（候选词窗口）主题。该文件由 fcitx5 自行生成，但内容全是用户偏好、
    # 无易变状态，故整体托管；fcitx5 GUI 里的改动会在下次 switch 时被覆盖回此处。
    #
    # Theme 与 DarkTheme 指向同一个变体：桌面已是纯深色，不需要浅色分支，
    # 这样候选词窗的观感就与"系统明暗检测"无关了。上一版依赖的是
    # gtk.colorScheme → dconf → xdg-desktop-portal → fcitx5 跟随系统 这条链，
    # 现在不再需要（UseDarkTheme 的语义确实是"跟随系统"而非"强制深色"）。
    #
    # UseAccentColor 取的是 portal 上报的系统重点色。这里置 False，
    # 否则它会用 #3584e4 盖掉主题自带的 mauve #ca9ee6；而本机 GNOME 的
    # accent-color 只接受命名值（blue/teal/…），根本钉不到壳层的 #0088FF，
    # 与其留一个近似蓝，不如用主题自带色。
    xdg.configFile."fcitx5/conf/classicui.conf".text = ''
      # 垂直候选列表
      Vertical Candidate List=False
      # 使用鼠标滚轮翻页
      WheelForPaging=True
      # 字体：与 GTK 界面字体一致（12pt）。
      # 主题里的 [InputPanel] Font 不会被 fcitx5 消费（上游
      # src/ui/classic/inputwindow.cpp 用的是 classicui.conf 的 Font，
      # theme.cpp 里唯一的字体用途是 trayFont），所以这里设的就是最终值。
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
      # 主题（浅色模式）：与深色同值，见上方说明
      Theme=catppuccin-frappe-mauve
      # 深色主题
      DarkTheme=catppuccin-frappe-mauve
      # 跟随系统浅色/深色设置
      UseDarkTheme=True
      # 使用系统重点色：关闭，否则会盖掉主题自带的 mauve
      UseAccentColor=False
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
