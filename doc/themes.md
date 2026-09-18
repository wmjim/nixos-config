# 主题与外观

配置位置：`modules/home-manager/gui/themes/default.nix`（Qt/GTK）+ `modules/home-manager/gui/wm/default.nix`（Niri 配色）+ `modules/home-manager/gui/fcitx5.nix`（输入法候选窗）。

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
| 输入法候选窗 | **mellow-youlan-dark** | fcitx5 `classicui.conf`，`UseDarkTheme=True`，字体与界面一致（12pt） |
| GNOME Shell / GDM | MacTahoe | GDM 侧靠 overlay 覆盖 `gnome-shell-theme.gresource`（见 `modules/nixos/desktop/gnome/default.nix`） |
| Niri 壳层配色 | MacTahoe-Dark 同源 | 由 `niri-colors/{layout,overview}.kdl` 生成；强调色 `#0088FF`、中性面 `#333333`/`#242424`、紧急 `#ED5F5D`，全部取自 MacTahoe-Dark 的 `gtk-4.0/gtk.css` |
| Noctalia Shell | Catppuccin（暗色） | 内置主题，界面字体 HarmonyOS Sans SC |

## 字体

- 界面字体：HarmonyOS Sans SC（12pt）
- 中文衬线阅读：LXGW WenKai（霞鹜文楷）
- 代码 / 终端：Maple Mono Normal NL NF（CN）
- 中文兜底：Noto Sans/Serif CJK SC（fontconfig 别名加固，防止国产 Qt 应用缺字方块）

## Niri 视觉细节

- 窗口间距 8px，单列工作区自动居中
- 焦点环 3px，单一强调色 `#0088FF`（macOS 范式：强调色不用渐变）
- 窗口圆角 12px（`windowrules.kdl` 的 `geometry-corner-radius`），禁用边框

  **为什么是 12px**：MacTahoe 自绘 CSD 的圆角是 24px（`window.csd { border-radius: 24px }`），而不自绘圆角的应用（Electron / Chromium / X11：VSCode、Discord、QQ、Telegram、Zotero、Typora、Anki、Steam）只能由合成器裁切。取 12px 与 MacTahoe 给 popover/menu/OSD 的二级圆角同阶，且小于 24px，保证裁切区域完全落在 CSD 窗口自身圆角之内、不会切掉它。
- 标签指示器在列右侧，圆角 8px；**仅当列进入 tabbed 显示模式（`Mod+W`）时出现**
- 概览缩放 0.40，背景 `#242424`
- 模糊 `passes 4 / offset 5.0 / saturation 1.10`
- 窗口开/关动画 240ms / 300ms（水波纹 shader）

### 两处容易搞错的 niri 语义

改动这套配色时踩到过，记录避免重蹈：

- **`focus-ring.inactive-color` 在单显示器上永不可见**。焦点环只围绕每块显示器上的活动窗口，所以 inactive-color 只会在非焦点显示器上出现（niri wiki, Configuration: Layout）。它不是什么“非焦点窗口的描边”。
- **`overview.backdrop-color` 的 alpha 通道会被忽略**（niri wiki, Configuration: Miscellaneous），写成 `#242424cc` 与 `#242424` 等价。

## 双层配色模型

壳层与工作区分属两套家族，这是**刻意的**，不是遗漏：

| 层 | 家族 | 元 |
|---|---|---|
| 壳层：niri 装饰 + GTK + Qt + 输入法 | macOS 中性灰 + 单一强调色 `#0088FF` | MacTahoe-Dark 的 `gtk-4.0/gtk.css` |
| 工作区：终端 + 编辑器 + shell | Catppuccin Frappe（`#303446` 底） | 冷调、低饱和 |

选这个组合的理由：一是 GTK/GDM/图标/自打包已经全部在 MacTahoe 上，二是“macOS 壳 + 低饱和冷调工作区”比单纯的全局 Catppuccin 更有辨识度。

### 尚未收口的几处

| 项 | 现状 | 说明 |
|---|---|---|
| Noctalia 内置 Catppuccin 的 flavor | 未指定 | Catppuccin 有 4 个 flavor，而 foot/nvim 钉的是 Frappe。若 bar 看起来比终端更黑更紫，说明内置取的是 Mocha，需在 Noctalia 主题面板对齐 |
| yazi | `everforest-medium` | 与终端 Frappe 属不同家族，可换成 `catppuccin-frappe` |
| btop | 自带默认主题 | 未配置；它在 foot 里半透明显示，是整块可见颜色 |
| fastfetch | 硬编码靖蓝渐变 | `assets/fastfetch/nixos-01.jsonc` 里写死 `#5277C3 → #7DAEDD` |
| fcitx5 候选窗重点色 | portal accent `#3584e4` | `UseAccentColor=True` 取的是 portal 上报色；而 `org.gnome.desktop.interface accent-color` 在本机 GNOME 版本只接受命名值（blue/teal/...），钉不到 `#0088FF`，故有细微色差 |
| 壁纸 | 未纳管 | `assets/wallpapers/` 是空目录，实际壁纸在未跟踪的 `~/Pictures/wallpaper/`；而模糊与半透明的观感直接吃壁纸 |

## 相关命令

```bash
# 查看系统级主题
ls /run/current-system/sw/share/themes/

# 光标主题目录（XWayland 应用）
ls ~/.local/share/icons/
```
