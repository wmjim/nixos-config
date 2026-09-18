# 主题与外观

配置位置：`modules/home-manager/gui/themes/default.nix`（Qt/GTK）+ `modules/home-manager/gui/wm/default.nix`（Niri 配色）+ `modules/home-manager/gui/wm/noctalia.nix`（Noctalia 调色板）+ `modules/home-manager/gui/fcitx5.nix`（输入法候选窗）。

整个桌面统一为**深色**：niri / Noctalia / 终端 / 编辑器都是深色，GTK/Qt/输入法也一并为深色，避免白底窗口浮在深色桌面上。

## 主题栈

| 项目 | 主题 | 说明 |
|------|------|------|
| GTK3 | **MacTahoe-Dark** | 自定义打包主题（`pkgs/mactahoe-gtk-theme`） |
| GTK4 / libadwaita | **MacTahoe-Dark** | 须显式设 `gtk.gtk4.theme`：HM 26.05 起其默认值为 `null`，不设就不会生成 `gtk-4.0/gtk.css`，应用会退回原生 Adwaita |
| color-scheme | **dark** | `gtk.colorScheme`；写 dconf `color-scheme=prefer-dark` 与 GTK4 的 `gtk-interface-color-scheme=2`，libadwaita 依此判定深色 |
| 图标 | **MacTahoe-dark** | 自定义打包图标（`pkgs/mactahoe-icon-theme`），为深色背景设计 |
| 光标 | **Bibata-Modern-Classic** | 24px，XWayland 亦生效（软链到 `~/.local/share/icons`） |
| Qt | **Kvantum + MacTahoeDark** | `QT_STYLE_OVERRIDE=kvantum`；主题来自自打包的 `pkgs/mactahoe-kvantum`（与 GTK 侧同一个上游作者），见下文 |
| 输入法候选窗 | **catppuccin-frappe-mauve** | `classicui.conf` 托管主题，圆角 8px（上游 SVG 烘焦的"弹窗"档，小于窗口半径，符合 concentricity）；归"工作区"一侧而非壳层 |
| GNOME Shell / GDM | MacTahoe | GDM 侧靠 overlay 覆盖 `gnome-shell-theme.gresource`（见 `modules/nixos/desktop/gnome/default.nix`） |
| Niri 壳层配色 | MacTahoe-Dark 同源 | 由 `niri-colors/{layout,overview}.kdl` 生成；强调色 `#0088FF`、中性发丝线 `#999999`（焦点环）、中性面 `#333333`/`#242424`、紧急 `#ED5F5D`，全部取自 MacTahoe-Dark 的 `gtk-4.0/gtk.css` |
| Noctalia Shell | **自定义调色板 `mactahoe`** | `customPalettes.mactahoe`，色值与 GTK/Qt/niri 同源；界面字体 HarmonyOS Sans SC。**仅调色板归 Nix，bar 布局归 GUI**，见下文 |

## 字体

- 界面字体：HarmonyOS Sans SC（12pt）
- 中文衬线阅读：LXGW WenKai（霞鹜文楷）
- 代码 / 终端：Maple Mono Normal NL NF（CN）
- 中文兜底：Noto Sans/Serif CJK SC（fontconfig 别名加固，防止国产 Qt 应用缺字方块）

## Niri 视觉细节

- 窗口间距 16px（见下），单列工作区自动居中（有意为之的"专注模式"，`Mod+F` 可把单列铺满）
- 焦点环 2px，中性发丝线 `#999999`（**用中性色而不是强调色**，理由见下）
- 窗口圆角 **24px**（`windowrules.kdl` 的 `geometry-corner-radius`），禁用边框。取值参考 macOS 的 concentricity 阶梯，见下
- 标签指示器在列右侧，圆角 8px（3px 宽的条，半径大于半宽就是胶囊，同主题的"药丸"档）；**仅当列进入 tabbed 显示模式（`Mod+W`）时出现**
- 概览缩放 0.40，背景 `#242424`
- `recent-windows` 高亮框圆角 12px（主题阶梯里的"独立弹层"档）
- 模糊 `passes 4 / offset 5.0 / saturation 1.10`；终端（foot / btop）`opacity 0.85`，取值按亮壁纸下的文字对比定，见 `frosted-glass.kdl`
- 窗口阴影由合成器提供（`shadow { on }`，参数由 MacTahoe 自己的 CSD 阴影反推，见下）
- 窗口开/关动画 240ms / 300ms（水波纹 shader）

### 圆角为何是 24px：参考 macOS 的 concentricity

Apple 在 WWDC 2025 的 *Build an AppKit app with the new design* 里把新设计概括为 **concentricity**：每个内层元素的曲率都落在容器圆角之内（`r_inner = r_outer − inset`），而且**窗口圆角随窗口样式变化**：

> *“Windows with toolbars now use a larger radius … Titlebar-only windows retain a smaller corner radius.”*

对应数值：Tahoe 的标题栏型窗口默认为 **16**，带工具栏的用更大的半径；Sequoia（macOS 15）为 **10**（来源：`m4rkw/macos-corner-fix` 的对照表）。

MacTahoe-Dark 在 `gtk-4.0/gtk.css` 里实现的正是这套阶梯，基准 **24**：

| 半径 | 选择器 | 层级 |
|---|---|---|
| **24px** | `window.csd` | 窗口本身 |
| 24px | `floating-sheet` / `bottom-sheet > sheet` | 独立浮动面板 |
| 19px | `notebook.frame` | 嵌在窗口内（24−5） |
| 18px | `.sidebar-pane` / `.content-pane` | 嵌在窗口内（24−6） |
| 16px | `notebook > header` | 嵌套更深 |
| 14px | `notebook > tabs > tab` | 嵌套更深 |
| 12px | `popover` / `menu` / `osd` | 独立弹层 |
| 6px | 按钮 / 输入框 | 控件 |
| 9999px | 药丸 | 胶囊 |

**为何取主题的 24 而不是字面的 16**：内层元素是 18/19px，把窗口压到 16 会让内层比外层更圆，必须连带重写窗口 + 侧边栏 + notebook + tab 共 5 个选择器（via `gtk.gtk{3,4}.extraCss`），且主题更新后会静默失配。取 24 则**零主题覆盖**，而且 GTK 自绘（24）与不自绘圆角的应用（Electron / Chromium / X11：VSCode、Discord、QQ、Telegram、Zotero、Typora、Anki、Steam）终于一致——这才是这套圆角在修的事。macOS 的 24 属于"带工具栏窗口"那一档，与本机以工具栏密集型应用为主的实际场景相符。

**阴影：由合成器接管（之前的"代价"已消解，而且我之前的判断也算错了）**

我把 `clip-to-geometry` 的影响误判为"只裁掉角上的阴影三角（12px 时 123 px²、24px 时 494 px²）"。实际不是：niri 裁的是 `xdg_surface` 的 window geometry，而 GTK 的 CSD 阴影画在 geometry **之外**的边距里 —— 所以 CSD 自绘阴影是**整层消失**的（上下左右全没），这一点就写在 `clip-to-geometry` 的文档里（*“cut out any client-side window shadows”*）。

也就是说在开启合成器阴影之前，窗口是**完全没有任何阴影**的。现在由 niri 提供：

```kdl
shadow {
    on
    softness 32        // = MacTahoe 三层阴影里最大的 blur（0 12px 32px）
    spread 0           // = 三层模糊层的 spread 都是 0
    offset x=0 y=7     // = 三层偏移 3/7/12 按各自 alpha 加权的中值
    color "#00000059"   // ≈ 35%，三层在窗沿处叠加后的等效不透明度
}
```

推导过程写在 `modules/home-manager/gui/wm/default.nix` 的注释里。三个要点：

- **不会叠成两层**。niri 文档：设了 `prefer-no-csd` 与/或 `geometry-corner-radius` 之后，*“These will also remove client-side shadows if the window draws any.”* 而且无论 GTK 是否响应 `prefer-no-csd`（保留 CSD / 放弃 CSD），结论都一致：要么自绘阴影被裁、合成器补上，要么本来就没有
- `draw-behind-window` 保持默认 `false`——文档说只有"niri 不知道 CSD 圆角"时才需要 `true`；我们给了 `geometry-corner-radius`，niri 自己知道圆角，也就不会在半透明窗口（foot 0.85）里透出一圈暗影
- 阴影跟随 `geometry-corner-radius`（24px）绘制，天然与窗口同心

仍可选的另一条路：改回字面 macOS 值 16，并按 concentricity 把上表里 ≥ 18px 的选择器用 `gtk.gtk{3,4}.extraCss` 一并下移。

### 窗口间距为何是 16px

窗口圆角是 24px（`windowrules.kdl` 的 `geometry-corner-radius`，取值理由见上节）。间距若小于圆角，相邻两窗的圆角弧比它自己的半径还靠得近，缝隙看上去是"被掉住"而不是留白。原来的 8px 在 1.5 缩放下只有 12 物理像素；现在的 16px 能在两个 24px 的圆角之间留出一段直边，同时不至于把窗口推得过远。

`gaps` 同时作用于内缝隙与外留白。若以后想两者不同，niri 的官方写法是 `gaps 16` 配 `struts { left/right/top/bottom -8; }`，但负 struts 会把平铺区推到屏幕外，引入额外边界情况，故未采用。

### 焦点环为何是中性发丝线，而不是强调色

原来这里是 3px 的 `#0088FF`（饱和强调色），视觉上显得抢眼。换成了 2px 的 `#999999`。

**根本理由：Apple 从不把强调色放在窗口边界上。** macOS 用强调色标**控件**（按钮、输入框焦点、选中的列表行），窗口边界只靠中性发丝线（主题里就是 `rgba(255,255,255,.15)` 那一条，也是 Noctalia 调色板 `mOutline = #454545` 的来源）加阴影区分活动与否。所以那个 3px 饱和蓝边是整套改造里**唯一“不像 macOS”的地方** —— 它比任何别的元素都跳，正是因为它同时具备高饱和度和位置错误两个特点。

**宽度取 2 而不是 3**：niri 会把逻辑像素按缩放取整到物理像素。desktop 的 1.5 缩放下：

| width | 物理像素 | |
|---|---|---|
| 1 | 1.5 | ⚠️ 取整到 2 → 实际 1.33 逻辑 |
| **2** | **3.0** | ✅ 精确 |
| 3 | 4.5 | ⚠️ 落在半像素边界，只能跳成 4 或 5 → 实际 2.67~3.33 |
| 4 | 6.0 | ✅ 精确（但太粗） |

laptop 的 1.25 缩放下 2 仍不精确（2.5），**两台都精确的宽度只有 4、8**，那又太粗。所以取了 desktop 的精确值。

**为何不靠降不透明度来减重**：焦点环画在 16px 缝隙上，背景就是壁纸，而降不透明度在亮壁纸下会让它消失：

| 不透明度 | 压在暗壁纸 | 压在亮壁纸 |
|---|---|---|
| 100% | `#0088FF` | `#0088FF` |
| 60% | `#0E61AE` | `#66B8FF` |
| 45% | `#13528F` | `#8CC9FF` ← 亮度与壁纸几乎相同，**提示失效** |

所以减重只能靠**宽度和色相**。`#999999` 在两种壁纸上都立得住（暗壁纸 5.4:1、亮壁纸 2.9:1），而纯白在亮壁纸上会消失。

两个选它的依据：它在 MacTahoe-Dark 的 `gtk-4.0/gtk.css` 里（出现 3 次），而 niri 自己（`default-config.kdl`）也把它当作 recent-windows 高亮框的默认中性色。

想换回强调色就把 `active-color` 改回 `#0088FF`；想恢复原粗细就把 `width` 改回 3。都在 `wm/default.nix` 的 `layoutKdl` 里。

### 两处容易搞错的 niri 语义

改动这套配色时踩到过，记录避免重蹈：

- **`focus-ring.inactive-color` 在单显示器上永不可见**。焦点环只围绕每块显示器上的活动窗口，所以 inactive-color 只会在非焦点显示器上出现（niri wiki, Configuration: Layout）。它不是什么“非焦点窗口的描边”。
- **`overview.backdrop-color` 的 alpha 通道会被忽略**（niri wiki, Configuration: Miscellaneous），写成 `#242424cc` 与 `#242424` 等价。

## Qt：从 Adwaita 换成 Kvantum

**问题**：Qt 侧原先用 `adwaita-dark`（Fedora 的 Adwaita Qt 移植）。Adwaita 是另一套设计语言——控件形状、按钮、输入框都与 MacTahoe 无关，而本机有 VLC（UI 面积最大）、Telegram、qView、fcitx5 配置工具四个 Qt 应用，它们的菜单 / 对话框 / 工具条会明显“不像这个桌面”。

**方案**：Kvantum（SVG 驱动的 Qt 样式引擎）+ `vinceliuice/MacTahoe-kde` 的 Kvantum 组件——**与 GTK 侧的 MacTahoe 是同一个上游作者**，本来就是配套的。

自打包为 `pkgs/mactahoe-kvantum`，只取上游的 Kvantum 部分（plasma / aurorae / look-and-feel 面向 Plasma 桌面，与本机无关，装进来只增大闭包）。三处工程细节：

1. **主题包进 `home.packages`，不用 `qt.kvantum.themes`。** 后者会把 `~/.config/Kvantum` 整个做成指向 store 的软链，而 `kvantum.kvconfig` 又要写在同一目录下，两者会打架。装进 profile 后落在 `XDG_DATA_DIRS`，Kvantum 同样会在那里搜主题（上游自己的 `install.sh` 就是装到 `share/Kvantum`）。

2. **主题名取 `MacTahoeDark` 而不是 `MacTahoe`。** Kvantum 选浅色还是深色取决于应用的 QPalette 明暗，而非 Plasma 会话下这个值来自平台主题，并不可靠。上游目录里浅深两态并存（`MacTahoe.kvconfig` / `MacTahoeDark.kvconfig`），Kvantum 的规则是“主题 T → `T.kvconfig`；若应用偏暗且存在 `TDark.kvconfig` 则改用它”——所以把深色那一对单独命名为主题 `MacTahoeDark` 后，选中它必然命中深色档（它要去找的 `MacTahoeDarkDark.kvconfig` 并不存在）。与本仓库其余部分“只用深色”一致。

3. **强调色对齐壳层。** 上游 kvconfig 用 `#a0b4f8`（浅紫蓝）作 highlight，而同一个作者的 GTK 主题用的是 `#0088FF`——同源却不同色。打包时把 highlight / inactive.highlight / link 统一到 `#0088FF`，与 GTK、Noctalia 的 `mPrimary` 一致（
   焦点环是例外，它故意不用强调色，见上文）。

**`platformTheme` 保持 `adwaita` 不动**：Wayland 下 Qt 的窗口装饰由平台主题提供，与控件样式是两回事；换掉它会让自绘标题栏消失（`env.nix` 里就是为此才恢复 Qt 自绘）。所以现状是“控件 = Kvantum/MacTahoe，标题栏 = QAdwaitaDecorations”。

**未验证的一点**：MacTahoeDark 的底色 / 文字本来就与 MacTahoe-Dark 的 GTK 值一致（`window.color=#242424`、`text.color=#dedede`、`tooltip.base.color=#333333`，可直接 grep 自打包产物复核），但 Kvantum 的实际渲染要打开 VLC 或 Telegram 看一眼才算数。

## 双层配色模型

壳层与工作区分属两套家族，这是**刻意的**，不是遗漏：

| 层 | 家族 | 元 |
|---|---|---|
| 壳层：niri 装饰 + GTK + Qt + Noctalia bar | macOS 中性灰 + 单一强调色 `#0088FF` | MacTahoe-Dark 的 `gtk-4.0/gtk.css` |
| 工作区：终端 + 编辑器 + shell + 文件管理器 + 系统监控 + 输入法候选窗 | Catppuccin Frappe（`#303446` 底） | foot、Neovim、yazi、btop、fastfetch、fcitx5 六处同源 |

输入法候选窗归到工作区而非壳层，理由：它是跟随文本光标出现的**打字层**浮层，同屏的总是终端 / 编辑器 / 浏览器，而那些都是 Frappe。

选这个组合的理由：一是 GTK/GDM/图标/自打包已经全部在 MacTahoe 上，二是“macOS 壳 + 低饱和冷调工作区”比单纯的全局 Catppuccin 更有辨识度。

**定调：以应用层为主体。** bar 应当退到背景里，而不是与窗口争主体。这条决定了下面 Noctalia 一节的取舍。

## Noctalia：调色板归 Nix，其余归 GUI

这是最容易误解的一块，先讲清机制。

```
programs.noctalia.settings  →  ~/.config/noctalia/config.toml      ← Nix 管理
                                        ↓  被运行时覆盖
GUI 里的任何改动            →  ~/.local/state/noctalia/settings.toml ← 真实状态，Nix 管不到
```

模块自己的文档写着（`nix/home-module.nix`）：

> *“Default settings for noctalia … **Note: these settings can still be overwritten at runtime via the settings menu.**”*

所以 Nix 里的 `settings` **只是出厂默认值**。实测对账：

| 键 | 仓库里声明的 | 实际生效的 |
|---|---|---|
| `theme.builtin` | `Catppuccin` | —（已删，见下） |
| `audio.enable_sounds` | `false` | **`true`**（关音效的意图被推翻） |
| `brightness.enable_ddcutil` | laptop 上 `false` | desktop 实测 `true`（laptop 需单独核） |
| `shell.font_family` / `audio.sound_volume` | 有声明 | 不在 settings.toml → **生效** ✅ |

**职责划分（这是决定，不是妥协）**：

- **调色板归 Nix**：`programs.noctalia.customPalettes.mactahoe` 写 `~/.config/noctalia/palettes/mactahoe.json`，配合 `theme.source = "custom"`。这是唯一能在版本控制里钉死“MacTahoe 中性灰 + `#0088FF`”的入口
- **bar 布局 / 控件 / 插件归 GUI**：那些在 `settings.toml` 里，而那个文件包含明文插件 API key（`deepseek_usage.api_key`）。托管它等于把密钥写进全局可读的 store，与当初 WinApps RDP 密码做到一半的判断一个道理，所以不做
- 因此 `theme.source` 即使写在 Nix 里，**首次也需在 GUI 选一次**，或跑：

  ```bash
  noctalia msg color-scheme-set custom mactahoe
  noctalia msg color-scheme-get        # 应回：custom mactahoe
  ```

  若调色板文件有问题，noctalia 会在日志里报 `custom palette 'mactahoe' not found or invalid; falling back to builtin`。

### 调色板取值为何不用社区方案 ADW

社区调色板 ADW 的 `mSurface` 恰好也是 `#242424`，但其余色槽映射有误，故重做：

| 色槽 | ADW | 问题 | 本仓库取值 |
|---|---|---|---|
| `mOnSurfaceVariant` | `#ffffff` | 与 `mOnSurface` 相同 → **没有文字层级** | `#afafaf`（MacTahoe 次级前景） |
| `mSecondary` | `#1b467c` | 暗海军蓝，在 `#242424` 上几乎看不见 | `#2e7cf7`（同族第二蓝） |
| `mTertiary` | `#ffffff` | 纯白当强调色，且与文字色重复 | `#4dacff`（同族亮蓝） |
| `mPrimary` | `#3584e4` | GNOME 蓝，不是壳层强调色 | `#0088ff` |
| `mHover` | `#3584e4` | 饱和强调色当悬浮底色（文档约定是柔和提亮） | `#3d3d3d`（唯一插值项） |
| `mSurfaceVariant` | `#1e1e1e` | 比主面更暗，层叠方向反了 | `#333333` |
| `mOnSurface` | `#ffffff` | 比 MacTahoe 的 `#dedede` 刺眼 | `#dedede` |
| `mOutline` | `#3d3846` | 紫调灰，与中性壳层不同族 | `#454545`（= MacTahoe 的 `rgba(255,255,255,.15)` 发丝边合成值） |

### bar 收敛目标（GUI 侧执行）

当前 19 个控件、`background_opacity = 0.15`。以应用层为主体后应当退到背景，但不是退回隐形。

**透明度是可算的，不该拍脑袋。** 合成永远是“`opacity` × 底色 + (1−`opacity`) × 模糊后的壁纸”，而壁纸是经常更换的自由变量，所以按**最坏情况（模糊后接近纯白）** 定值：

```
bar（文字 #DEDEDE，底色 #242424）
  0.15  →  可见底色 #DEDEDE  对比 1.00:1  ❌ 文字完全消失
  0.35  →  可见底色 #B2B2B2  对比 1.58:1  ❌ 仍不可读
  0.50  →  可见底色 #929292  对比 2.31:1  ❌
  0.80  →  可见底色 #505050  对比 5.99:1  ✅ AA

终端（文字 #C6D0F5，底色 #303446）—— 参数在 frosted-glass.kdl
  0.70  →  对比 3.18:1  ⚠️        0.85  →  对比 5.06:1  ✅ AA
```

0.15 那行值得看一眼：`#242424` 的 15% 压在纯白上正好等于 `#DEDEDE`，与文字色**完全相同**，所以亮壁纸下 bar 的字是真的看不见。（早先我建议的 0.35 也是错的，同样不可读。）

| 项 | 当前 | 目标 | 理由 |
|---|---|---|---|
| `background_opacity` | 0.15 | **0.80** | 低于 0.80 时亮壁纸下文字对比低于 AA 4.5:1；“退到背景”应当是“低对比但可读”，不是“隐形” |
| `end`（12 个） | launcher, deepseek_usage, activity, cat, tray, clipboard, notifications, bluetooth, brightness, volume, theme_mode, session | **留 6**：tray, clipboard, notifications, volume, brightness, session | 两个第三方信息流（DeepSeek 用量、GitHub 动态）与第三个猫占的是最右端的视觉焦点 |
| `center`（4 个） | capsule(media+audio_visualizer), date, todo, notes | **留 date** | 音频可视化 + 待办/便签都属于“盯着看”的内容，与应用层争焦 |
| `start`（3 个） | workspaces, keymap, w-engine | **留 workspaces** | 键盘布局切换很少用 |
| `widget.cat.rave_mode` | `true` | `false` 或移除 | 动画在静止的壳层里是持续噪音 |

### 壁纸：**有意不纳管**

壁纸不写进 Nix，保持手动更换（Noctalia 面板或 `Mod+Alt+W`）。这是明确的决定，不是遗漏：

- 模糊与半透明的观感直接吃壁纸，而壁纸是要经常换的，纳管反而碍事
- 因此壁纸**不入 git**，`assets/` 下不再有 `wallpapers/` 目录
- 选壁纸的准则（配合 `saturation 1.10`）：大面积暗部、低彩度、少高频细节。`~/Pictures/wallpaper/` 里那些高彩度插画会被模糊 + 饱和度放大成“打翻的调色盘”

## 相关命令

```bash
# 查看系统级主题
ls /run/current-system/sw/share/themes/

# 光标主题目录（XWayland 应用）
ls ~/.local/share/icons/

# Noctalia 实际在用的调色板、以及调色板载入失败时的回退日志
noctalia msg color-scheme-get
grep -i "falling back to builtin" ~/.cache/noctalia/noctalia.log

# 校验 noctalia 配置（不依赖运行实例）
noctalia config validate ~/.config/noctalia/config.toml
```
