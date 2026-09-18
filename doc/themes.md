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
| Qt | **adwaita-dark** | `QT_STYLE_OVERRIDE=adwaita-dark`，包由 HM 依 style 名自动挑选（adwaita-qt + adwaita-qt6） |
| 输入法候选窗 | **catppuccin-frappe-mauve** | `classicui.conf` 托管主题，圆角 8px（上游 SVG 烘焦的"弹窗"档，小于窗口半径，符合 concentricity）；归"工作区"一侧而非壳层 |
| GNOME Shell / GDM | MacTahoe | GDM 侧靠 overlay 覆盖 `gnome-shell-theme.gresource`（见 `modules/nixos/desktop/gnome/default.nix`） |
| Niri 壳层配色 | MacTahoe-Dark 同源 | 由 `niri-colors/{layout,overview}.kdl` 生成；强调色 `#0088FF`、中性面 `#333333`/`#242424`、紧急 `#ED5F5D`，全部取自 MacTahoe-Dark 的 `gtk-4.0/gtk.css` |
| Noctalia Shell | **自定义调色板 `mactahoe`** | `customPalettes.mactahoe`，色值与 GTK/Qt/niri 同源；界面字体 HarmonyOS Sans SC。**仅调色板归 Nix，bar 布局归 GUI**，见下文 |

## 字体

- 界面字体：HarmonyOS Sans SC（12pt）
- 中文衬线阅读：LXGW WenKai（霞鹜文楷）
- 代码 / 终端：Maple Mono Normal NL NF（CN）
- 中文兜底：Noto Sans/Serif CJK SC（fontconfig 别名加固，防止国产 Qt 应用缺字方块）

## Niri 视觉细节

- 窗口间距 16px（见下），单列工作区自动居中（有意为之的"专注模式"，`Mod+F` 可把单列铺满）
- 焦点环 3px，单一强调色 `#0088FF`（macOS 范式：强调色不用渐变）
- 窗口圆角 **24px**（`windowrules.kdl` 的 `geometry-corner-radius`），禁用边框。取值参考 macOS 的 concentricity 阶梯，见下
- 标签指示器在列右侧，圆角 8px（3px 宽的条，半径大于半宽就是胶囊，同主题的"药丸"档）；**仅当列进入 tabbed 显示模式（`Mod+W`）时出现**
- 概览缩放 0.40，背景 `#242424`
- `recent-windows` 高亮框圆角 12px（主题阶梯里的"独立弹层"档）
- 模糊 `passes 4 / offset 5.0 / saturation 1.10`
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
- `draw-behind-window` 保持默认 `false`——文档说只有"niri 不知道 CSD 圆角"时才需要 `true`；我们给了 `geometry-corner-radius`，niri 自己知道圆角，也就不会在半透明窗口（foot 0.70）里透出一圈暗影
- 阴影跟随 `geometry-corner-radius`（24px）绘制，天然与窗口同心

仍可选的另一条路：改回字面 macOS 值 16，并按 concentricity 把上表里 ≥ 18px 的选择器用 `gtk.gtk{3,4}.extraCss` 一并下移。

### 窗口间距为何是 16px

窗口圆角是 24px（`windowrules.kdl` 的 `geometry-corner-radius`，取值理由见上节）。间距若小于圆角，相邻两窗的圆角弧比它自己的半径还靠得近，缝隙看上去是"被掉住"而不是留白。原来的 8px 在 1.5 缩放下只有 12 物理像素；现在的 16px 能在两个 24px 的圆角之间留出一段直边，同时不至于把窗口推得过远。

`gaps` 同时作用于内缝隙与外留白。若以后想两者不同，niri 的官方写法是 `gaps 16` 配 `struts { left/right/top/bottom -8; }`，但负 struts 会把平铺区推到屏幕外，引入额外边界情况，故未采用。

### 两处容易搞错的 niri 语义

改动这套配色时踩到过，记录避免重蹈：

- **`focus-ring.inactive-color` 在单显示器上永不可见**。焦点环只围绕每块显示器上的活动窗口，所以 inactive-color 只会在非焦点显示器上出现（niri wiki, Configuration: Layout）。它不是什么“非焦点窗口的描边”。
- **`overview.backdrop-color` 的 alpha 通道会被忽略**（niri wiki, Configuration: Miscellaneous），写成 `#242424cc` 与 `#242424` 等价。

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

当前 19 个控件、`background_opacity = 0.15`。以应用层为主体后应当退到背景，但不是退回隐形：

| 项 | 当前 | 目标 | 理由 |
|---|---|---|---|
| `background_opacity` | 0.15 | **0.35 ~ 0.40** | 15% 时 bar 自己的配色基本不起作用，文字直接压在模糊壁纸上；“退到背景”应当是“低对比但可读” |
| `end`（12 个） | launcher, deepseek_usage, activity, cat, tray, clipboard, notifications, bluetooth, brightness, volume, theme_mode, session | **留 6**：tray, clipboard, notifications, volume, brightness, session | 两个第三方信息流（DeepSeek 用量、GitHub 动态）与第三个猫占的是最右端的视觉焦点 |
| `center`（4 个） | capsule(media+audio_visualizer), date, todo, notes | **留 date** | 音频可视化 + 两且待办/便签都属于“盯着看”的内容，与应用层争焦 |
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
