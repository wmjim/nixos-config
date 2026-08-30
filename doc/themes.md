# 主题与外观

配置位置：`modules/home-manager/gui/themes/default.nix`（Qt/GTK）+ `modules/home-manager/gui/wm/default.nix`（Niri 配色）。

## 主题栈

| 项目 | 主题 | 说明 |
|------|------|------|
| GTK / GNOME Shell | **MacTahoe-Light** | 自定义打包主题（`pkgs/mactahoe-gtk-theme`） |
| 图标 | **MacTahoe-dark** | 自定义打包图标（`pkgs/mactahoe-icon-theme`） |
| 光标 | **Bibata-Modern-Classic** | 24px，XWayland 亦生效（软链到 `~/.local/share/icons`） |
| Qt | **adwaita** | adwaita-qt（platformTheme=adwaita） |
| Niri 布局配色 | Gruvbox Dark | 由 `niri-colors/layout.kdl` 生成（焦点环红橙渐变、标签指示器蓝色） |
| Noctalia Shell | Catppuccin（暗色） | 内置主题，界面字体 HarmonyOS Sans SC |

## 字体

- 界面字体：HarmonyOS Sans SC（12pt）
- 中文衬线阅读：LXGW WenKai（霞鹜文楷）
- 代码 / 终端：Maple Mono Normal NL NF（CN）
- 中文兜底：Noto Sans/Serif CJK SC（fontconfig 别名加固，防止国产 Qt 应用缺字方块）

## Niri 视觉细节

- 窗口间距 8px，单列工作区自动居中
- 焦点环 3px（非活动蓝、活动红橙渐变 45°）
- 窗口圆角 3px，禁用边框
- 标签指示器在列右侧，圆角 8px
- 概览缩放 0.40，背景 Gruvbox base03

## 相关命令

```bash
# 查看系统级主题
ls /run/current-system/sw/share/themes/

# 光标主题目录（XWayland 应用）
ls ~/.local/share/icons/
```
