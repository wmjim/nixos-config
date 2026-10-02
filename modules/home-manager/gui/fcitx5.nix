# Fcitx5 用户级配置
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mengw.gui.fcitx5;
  guiCfg = config.mengw.gui;

  rimeDir = "${config.home.homeDirectory}/.local/share/fcitx5/rime";

  # 记录上次部署时 rime 数据源指纹，用于判断是否需要清理构建缓存。
  # 放在 rime 目录之外，避免被 rime 当作自身数据文件处理。
  stampFile = "${config.home.homeDirectory}/.local/share/fcitx5/.rime-data-key";

  # 托盘里的输入法图标（详见 config 段开头说明）：三个状态字形。
  #
  # 字形取自桌面 UI 字体 HarmonyOS Sans SC Medium 的字形轮廓（U+62FC「拼」/ U+0041「A」），
  # 用 fontTools 转成 path 后**静态内联**在此：字体轮廓是固定几何，无需在构建期再跑一次转换，
  # 也就不必把 fontTools 拖进构建依赖。四边留白 11%（相对 em）——壳层会把 SVG 按比例
  # 撑满图标槽位，留白是唯一能控制字形视觉大小的旋钮；11% 大约对应 macOS 菜单栏里
  # 那个字符相对菜单栏高度的占比，**删掉留白字形会顶满槽位、比相邻图标还大**。
  # 颜色与 Noctalia 状态栏其它图标/文字对齐（实测拦图取色：暗色栏 #FFFFFF、亮色栏
  # #262626）。非 symbolic 图标不会被壳层重新着色，所以必须写死；两态各一套。
  imeIcons = onSurface: {
    # 中文态（fcitx5-rime 报的 fcitx-rime）：拼（对应 macOS 菜单栏的拼音图标）
    "fcitx-rime" = ''
      <svg xmlns="http://www.w3.org/2000/svg" width="27.43" height="27.98" viewBox="-80 37 1143 1166">
        <path fill="${onSurface}" d="M953 363V271H825V-77H734V271H568Q559 150 522.5 70.5Q486 -9 402 -93L323 -35Q379 18 410.5 62.5Q442 107 458.0 156.0Q474 205 479 271H366V363H483V404V574H400V663H535Q479 749 436 804L509 850Q557 790 615 705L554 663H690Q740 745 801 853L888 811Q837 726 795 663H935V574H825V363ZM358 358 266 327V41Q266 -20 241.5 -43.5Q217 -67 156 -67Q132 -67 84 -63L65 29Q101 23 138 23Q159 23 168.0 36.5Q177 50 177 81V296L52 252L30 348Q83 363 177 392V568H54V657H177V833H266V657H355V568H266V421L346 448ZM573 363H734V574H573V415Z" transform="scale(1,-1) translate(0,-1000)"/>
      </svg>
    '';
    # Rime 的 ascii_mode：A
    "fcitx_rime_latin" = ''
      <svg xmlns="http://www.w3.org/2000/svg" width="21.34" height="22.85" viewBox="-103 158 889 952">
        <path fill="${onSurface}" d="M382 732 676 0H559L484 196H187L115 0H7L290 732ZM448 290 332 592 222 290Z" transform="scale(1,-1) translate(0,-1000)"/>
      </svg>
    '';
    # 禁用态（Rime 暂停）：拼 + 斜杠
    "fcitx_rime_disable" = ''
      <svg xmlns="http://www.w3.org/2000/svg" width="27.43" height="27.98" viewBox="-80 37 1143 1166">
        <path fill="${onSurface}" d="M953 363V271H825V-77H734V271H568Q559 150 522.5 70.5Q486 -9 402 -93L323 -35Q379 18 410.5 62.5Q442 107 458.0 156.0Q474 205 479 271H366V363H483V404V574H400V663H535Q479 749 436 804L509 850Q557 790 615 705L554 663H690Q740 745 801 853L888 811Q837 726 795 663H935V574H825V363ZM358 358 266 327V41Q266 -20 241.5 -43.5Q217 -67 156 -67Q132 -67 84 -63L65 29Q101 23 138 23Q159 23 168.0 36.5Q177 50 177 81V296L52 252L30 348Q83 363 177 392V568H54V657H177V833H266V657H355V568H266V421L346 448ZM573 363H734V574H573V415Z" transform="scale(1,-1) translate(0,-1000)"/>
        <path d="M-11 1133 L994 107" stroke="#FFFFFF" stroke-width="103" stroke-linecap="round"/>
      </svg>
    '';
  };

  # 输入法图标要建在**两套** GTK 图标主题名下：theme-apply 会按模式把 gsettings 的
  # icon-theme 在 MacTahoe-{dark,light} 之间切（见 gui/themes/variants.nix），而 Noctalia
  # 的图标解析器是按**当前**主题名去 ~/.local/share/icons/<name>/scalable/apps 找图标 ——
  # 只建暗色那份的话，切到亮色后状态栏那个输入法图标会回退成默认图标（表现为“切了主题
  # 之后输入法的效果没了”）。两个名字与 theme-apply 切的 icon-theme 两个值保持一致。
  # 必须与之同名建一份**只有图标、没有 index.theme** 的薄覆盖层，原因见 config 段开头的说明。
  # 位置必须是 Qt 风格的 scalable/apps/：index.theme 缺失时 Noctalia 会用内置的
  # 回退目录表（src/system/icon_resolver.cpp）去搜，表里 scalable 在前，而
  # GTK 风格的 apps/scalable/ 不在表内。
  # 每份覆盖层配对应的字形色：hicolor 是兜底（只有主题名解析不到时才会用到，用暗色那份），
  # 两个主题名下各放与它匹配的一套 —— 否则浅色栏上是浅灰字形，等于看不见。
  imeIconDirs = [
    {
      dir = ".local/share/icons/hicolor/scalable/apps";
      onSurface = "#FFFFFF";
    }
    {
      dir = ".local/share/icons/MacTahoe-dark/scalable/apps";
      onSurface = "#FFFFFF";
    }
    {
      dir = ".local/share/icons/MacTahoe-light/scalable/apps";
      onSurface = "#262626";
    }
  ];

  # classicui.conf 的字面内容：两态只差三行（Theme / DarkTheme / UseDarkTheme），其余 40 余行
  # 共用，所以写成一个函数而不是两份。flavour 就是 Catppuccin 变体名，也是上游
  # catppuccin-fcitx5 主题目录名的中段（catppuccin-<flavour>-mauve）。
  classicuiConf = flavour: ''
    # 垂直候选列表
    Vertical Candidate List=False
    # 使用鼠标滚轮翻页
    WheelForPaging=True
    # 字体：与 GTK 界面字体一致（12pt）。
    # 主题里的 [InputPanel] Font 不会被 fcitx5 消费（上游
    # src/ui/classic/inputwindow.cpp 用的是 classicui.conf 的 Font，
    # theme.cpp 里唯一的字体用途是 trayFont），所以这里设的就是最终值。
    Font="HarmonyOS Sans SC 11"
    # 菜单字体
    MenuFont="HarmonyOS Sans SC Medium Medium 11"
    # 托盘字体
    TrayFont="HarmonyOS Sans SC Medium Medium 11"
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
    # 主题：每个模式下只装了一个变体，Theme 与 DarkTheme 都指它（见上面 config 段说明）
    Theme=catppuccin-${flavour}-mauve
    DarkTheme=catppuccin-${flavour}-mauve
    # 不跟随系统明暗：两态由 theme-apply 翻软链决定
    UseDarkTheme=False
    # 使用系统重点色：关闭，否则会盖掉主题自带的 mauve
    UseAccentColor=False
    # 在 X11 上针对不同屏幕使用单独的 DPI
    PerScreenDPI=False
    # 固定 Wayland 的字体 DPI
    ForceWaylandDPI=0
    # 在 Wayland 下启用分数缩放
    EnableFractionalScale=True
  '';

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
  # 候选窗主题直接用上游 catppuccin-fcitx5（自带 frappe/latte 两套 mauve 变体），不做任何
  # 后处理。特别注意：**不要**为「候选窗上的横竖残影」去改这套主题的素材或 Margin —— 实测
  # 那是 fcitx5 在 fractional scaling 下的渲染问题（见 docs/quirks.md），改主题毫无效果。
in
{
  options.mengw.gui.fcitx5.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Fcitx5 用户级配置（Rime）";
  };

  config = lib.mkIf (cfg.enable && guiCfg.enable) {
    home.packages = [ pkgs.catppuccin-fcitx5 ];

    # 经典界面（候选词窗口）主题。该文件由 fcitx5 自行生成，但内容全是用户偏好、
    # 无易变状态，故整体托管；fcitx5 GUI 里的改动会在下次 switch 时被覆盖回此处。
    #
    # Theme 与 DarkTheme 指向同一个变体：桌面已是纯深色，不需要浅色分支，
    # 这样候选词窗的观感就与"系统明暗检测"无关了。
    #
    # UseAccentColor 取的是 portal 上报的系统重点色。这里置 False，
    # 否则它会用 #3584e4 盖掉主题自带的 mauve #ca9ee6；而壳层强调色 #0088FF 是
    # 自定调色板里的值，portal 只报 GSettings 的默认蓝（GNOME 会话已移除，没人
    # 再设置它），根本钉不到 #0088FF，与其留一个近似蓝，不如用主题自带色。
    #
    # 亮/暗两态由 theme-apply 翻软链决定（两个变体都生成到 store，见下面
    # mengw.appearance.switchTargets），不依赖 fcitx5 自己的系统明暗探测：它跑在 Qt 上，
    # 那份探测在 niri 会话里并不可靠，而进程常驻开机以来就不重读配置，候选词窗又是打字层
    # 浮层、主题错了很扎眼。（启动时读一次这点无法绕过：切主题时 theme-apply 会重启它。）
    xdg.configFile."fcitx5/conf/classicui.conf" = {
      text = classicuiConf "frappe"; # 初始值 = 暗色（与改造前一致）
      # force：这个软链运行时归 theme-apply 接管，不跳过碰撞检查会让整份 HM 激活失败
      force = true;
    };
    xdg.configFile."theme-variants/fcitx5/classicui-dark.conf".text = classicuiConf "frappe";
    xdg.configFile."theme-variants/fcitx5/classicui-light.conf".text = classicuiConf "latte";

    mengw.appearance.switchTargets = [
      {
        live = ".config/fcitx5/conf/classicui.conf";
        dark = ".config/theme-variants/fcitx5/classicui-dark.conf";
        light = ".config/theme-variants/fcitx5/classicui-light.conf";
      }
    ];

    # fcitx5 全局快捷键：只留 Ctrl+Space 切输入法。
    #
    # AltTriggerKeys 默认是 Shift_L，会在 fcitx5 这层就把 Shift 截走（表现为切中/英），
    # Rime 的 ascii_composer 根本收不到——所以想让左右 Shift 的 inline_ascii 生效，必须
    # 在这里清空。enumerate（按住修饰键轮换 / Super+Space 切换分组）系列一并清空，
    # 避免它们再切一次输入法；未列出的键位保持 fcitx5 内置默认。
    #
    # 与 classicui.conf 同理：文件整体托管，fcitx5 GUI 里的改动会在下次 switch 被覆盖。
    xdg.configFile."fcitx5/config".text = ''
      [Hotkey]
      EnumerateWithTriggerKeys=False
      AltTriggerKeys=
      EnumerateForwardKeys=
      EnumerateBackwardKeys=
      EnumerateGroupForwardKeys=
      EnumerateGroupBackwardKeys=

      [Hotkey/TriggerKeys]
      0=Control+space
    '';

    # Rime 页大小补丁（default.custom.yaml）
    #
    # ── 托盘（Noctalia）里的输入法图标 ────────────────────────────────
    #
    # fcitx5 只经 D-Bus StatusNotifierItem 报一个图标名（中文态 fcitx-rime /
    # Rime 的 ascii_mode fcitx_rime_latin / 禁用态 fcitx_rime_disable），图片由壳层
    # 按图标主题解析。而 MacTahoe 图标主题**自己也带了** status/{16,22,24,32,symbolic}/
    # fcitx-rime.svg —— 上游那枚浅灰方章 logo，落到托盘槽位里有效字形只有 13px，
    # 在深色栏上就是一块灰扑扑的小方块（栏里其余图标 24px）。
    #
    # 解析顺序（Noctalia src/system/icon_resolver.cpp）：当前主题的目录 → 其继承主题
    # （hicolor、breeze）的目录 → …；主题内 scalable 优先、再按尺寸降序；同一主题内
    # .svg 又整体优先于 .png。所以只往 hicolor 放同名文件没用——当前主题的
    # status/24/fcitx-rime.svg 先被命中。必须建一份**与当前主题同名**的薄覆盖层，
    # 它因排在 baseDirs 首位（$XDG_DATA_HOME/icons）而天然优先。
    #
    # ⚠ 覆盖层里**绝对不能有 index.theme**（曾经写过，后果是把文件管理器里的文件/文件夹
    #   图标全换成了 Adwaita 默认值）：GTK/Qt 解析主题时一旦在本层号里找到 index.theme，
    #   就把这层号当成整个主题的根，而覆盖层里只有三个图标文件，主题自带的 places/*、
    #   mimes/*（文件夹/文件类型图标）与 apps/16..32（应用图标）随之全部落空，全体回退到
    #   默认主题。没有 index.theme 时：GTK/Qt 直接忽略本层号（它们只认 index.theme），而
    #   Noctalia 会改用内置的回退目录表去搜（同一函数里的 FALLBACK：/scalable/apps/、
    #   /512x512/apps/、…、/48x48/apps/、/），于是**只对壳层生效、对其他应用零影响**
    #   （已实测：加与不加，nautilus 窗口渲染逐像素相同）。
    #
    # 因为走的是 Noctalia 的回退目录表，文件必须放在 Qt 风格的 scalable/apps/ 下
    # （GTK 风格的 apps/scalable/ 不在那张表里）。
    #
    # hicolor 那份（同样三个字形）是兜底：换成不带 fcitx-rime 的图标主题时，覆盖层
    # 不再被搜索，图标会回落到 fcitx5-rime 包自带的 SVG，此时 hicolor 版本生效。
    #
    # ⚠ Noctalia 缓存每个托盘项解析到的图标路径：改完图标后如果栏里没变，重启一次
    #   noctalia（或等该项图标名随输入法状态变化）即可。
    home.file = {
      ".local/share/fcitx5/rime/default.custom.yaml".text = ''
        patch:
          __include: wanxiang_suggested_default:/
          __patch:
            menu/page_size: 7
            # 万象默认 Shift_L/Shift_R 都是 commit_code（上屏编码再切英文）。
            # 两键统一改回 inline_ascii：进临时英文模式，回车才上屏、回到中文态。
            ascii_composer/switch_key/Shift_L: inline_ascii
            ascii_composer/switch_key/Shift_R: inline_ascii
      '';
    }
    # 三个状态字形 × 两处放置位置（当前主题覆盖层 + hicolor 兜底）
    // lib.listToAttrs (
      lib.concatMap (
        d:
        lib.mapAttrsToList (name: text: {
          name = "${d.dir}/${name}.svg";
          value = { inherit text; };
        }) (imeIcons d.onSurface)
      ) imeIconDirs
    );

    # 只在数据源指纹变化时才清理，避免每次 switch 都触发全量重建。
    # 仅删除 build/（纯派生产物）；用户词典 *.userdb、*.gram、sync/ 均保留。
    home.activation.rimeBuildCacheInvalidate = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
