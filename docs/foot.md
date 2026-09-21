# Foot 终端

配置位置：`modules/home-manager/gui/apps/foot.nix`，配色为 **Catppuccin Frappe**（与 Neovim 配色同源）。

仅支持 Wayland，macOS 主机不使用。

## 常用命令

- 校验配置：`foot --check-config`（默认读 `~/.config/foot/foot.ini`）
- 查看版本与编译期特性：`foot --version`
- 指定 app-id 启动（供 niri 窗口规则匹配）：`foot --app-id=btop -e btop`

## 配置要点

| 配置项 | 值 |
|--------|-----|
| 字体 | Maple Mono Normal NL NF，12pt（`dpi-aware=no`，字号随输出缩放） |
| 内边距 | 8x6（左右 x 上下） |
| 滚动历史 | 10000 行 |
| 光标 | 块状 + 闪烁 |
| 选中即复制 | 开启（`selection-target=both`，同时写入 primary 与 clipboard） |
| 输入时隐藏鼠标 | 开启 |
| 终端类型 | foot（远端主机没装 foot terminfo 才会报 unknown terminal type，故不随上游默认） |
| 不透明度 | 1.0（半透明由 niri 窗口规则控制，见 `wm/config/visual/frosted-glass.kdl`） |

## 快捷键

| 快捷键 | 功能 |
| --- | --- |
| `Ctrl` + `Shift` + `C` | 复制到剪贴板 |
| `Ctrl` + `Shift` + `V` | 从剪贴板粘贴 |
| `Shift` + `Insert` | 粘贴 primary 选区 |
| `Ctrl` + `Shift` + `R` | 滚动历史搜索（正则） |
| `Ctrl` + `Shift` + `O` | URL 模式（跳转标签打开链接） |
| `Ctrl` + `Shift` + `N` | 新窗口 |
| `Ctrl` + `=` / `-` | 增大 / 减小字号 |
| `Ctrl` + `0` | 重置字号 |
| `F11` | 全屏切换（本配置补充，foot 默认无此绑定） |

在 Niri 下，`Super` + `C` / `X` / `V` 由 `niri-clip` 翻译为上述 `Ctrl` + `Shift` 键位后送达 foot（见 `modules/home-manager/gui/wm/default.nix`），与 GUI 应用保持一致；上表的 `Ctrl` + `Shift` 键位是翻译后的接收端键位，已显式写入 `foot.ini`。

鼠标选中即复制；`Shift` + 拖拽可绕过应用自身的鼠标捕获进行选择。foot 没有 Alacritty 的 Vi 模式，历史检索用 `Ctrl` + `Shift` + `R`。
