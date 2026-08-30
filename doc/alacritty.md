# Alacritty 终端

配置位置：`modules/home-manager/gui/apps/alacritty.nix`，主题为 **Catppuccin Frappe**。

## 常用命令

- 列出所有可用主题：`alacritty themes list`
- 查看当前生效配置：`alacritty migrate --dry-run`（检查配置是否有问题）

## 配置要点

| 配置项 | 值 |
|--------|-----|
| 字体 | Maple Mono Normal NL NF，12pt |
| 不透明度 | 1.0（完全不透明） |
| 滚动历史 | 10000 行 |
| 光标 | 块状 + 闪烁 |
| 选中即复制 | 开启（save_to_clipboard） |
| 输入时隐藏鼠标 | 开启 |
| 终端类型 | xterm-256color |

## 快捷键

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl` + `Shift` + `C` | 复制 |
| `Ctrl` + `Shift` + `V` | 粘贴 |
| `Ctrl` + `Shift` + `F` | 搜索（正则） |
| `Ctrl` + `Shift` + `Space` | 进入 Vi 模式（移动/选择/复制） |
| `Ctrl` + `=` / `-` | 增大 / 减小字号 |
| `Ctrl` + `0` | 重置字号 |
| `Ctrl` + `Shift` + `N` | 新窗口 |
| `F11` | 全屏切换 |
