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
| Niri 布局配色 | Gruvbox Dark | 由 `niri-colors/layout.kdl` 生成（焦点环红橙渐变、标签指示器蓝色）——**尚未与应用侧配色收敛，见下文** |
| Noctalia Shell | Catppuccin（暗色） | 内置主题，界面字体 HarmonyOS Sans SC |

## 字体

- 界面字体：HarmonyOS Sans SC（12pt）
- 中文衬线阅读：LXGW WenKai（霞鹜文楷）
- 代码 / 终端：Maple Mono Normal NL NF（CN）
- 中文兜底：Noto Sans/Serif CJK SC（fontconfig 别名加固，防止国产 Qt 应用缺字方块）

## Niri 视觉细节

- 窗口间距 8px，单列工作区自动居中
- 焦点环 3px（非活动蓝、活动红橙渐变 45°）
- 窗口圆角 12px（`windowrules.kdl` 的 `geometry-corner-radius`），禁用边框

  **为什么是 12px**：MacTahoe 自绘 CSD 的圆角是 24px（`window.csd { border-radius: 24px }`），而不自绘圆角的应用（Electron / Chromium / X11：VSCode、Discord、QQ、Telegram、Zotero、Typora、Anki、Steam）只能由合成器裁切。取 12px 与 MacTahoe 给 popover/menu/OSD 的二级圆角同阶，且小于 24px，保证裁切区域完全落在 CSD 窗口自身圆角之内、不会切掉它。
- 标签指示器在列右侧，圆角 8px
- 概览缩放 0.40，背景 Gruvbox base03

## 已知待收敛项

合成器壳层（Gruvbox Dark）与应用侧（MacTahoe 中性灰 + `#0088FF`、终端 Catppuccin Frappe、yazi Everforest）仍是多套配色。收敛方案见 `doc/` 内讨论。

## 相关命令

```bash
# 查看系统级主题
ls /run/current-system/sw/share/themes/

# 光标主题目录（XWayland 应用）
ls ~/.local/share/icons/
```
