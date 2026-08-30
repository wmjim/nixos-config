# Niri 快捷键

Niri 配置文件位于 `modules/home-manager/gui/wm/config/`（symlink 到 `~/.config/niri`），`Mod` = `Super`（Windows 键）。

按 `Mod` + `/` 可随时呼出快捷键查看器（alacritty + fzf）。

## 应用启动

| 快捷键 | 功能 |
|--------|------|
| `Mod` + `Space` | Noctalia 应用启动器 |
| `Mod` + `T` | 终端（Alacritty） |
| `Mod` + `B` | 浏览器（Zen） |
| `Mod` + `C` | VSCode |
| `Mod` + `E` | 文件管理器（Nautilus） |
| `Mod` + `Shift` + `M` | 系统监控（btop） |
| `Alt` + `T` | Pot 划词翻译 |
| `Alt` + `I` | Pot 输入翻译 |
| `Alt` + `X` | Pot 截屏翻译（OCR） |
| `Mod` + `Alt` + `P` | PicGo 上传剪贴板图片 |
| `Mod` + `Shift` + `S` | Snipaste 截图 |

## 工作区

| 快捷键 | 功能 |
|--------|------|
| `Mod` + `U` / `I` | 下一个 / 上一个工作区 |
| `Mod` + `Ctrl` + `U` / `I` | 当前窗口移至下 / 上一个工作区 |
| `Ctrl` + `Shift` + `R` | 重命名工作区 |
| `Mod` + `1`~`9` | 切换到工作区 1-9 |
| `Mod` + `Ctrl` + `1`~`9` | 当前窗口移至工作区 1-9 |
| `Mod` + `Shift` + `U` / `I`（或 `Page_Up/Down`） | 工作区整体上 / 下移 |

## 窗口管理

| 快捷键 | 功能 |
|--------|------|
| `Mod` + `Q` | 关闭当前窗口 |
| `Mod` + `F` | 最大化列 |
| `Mod` + `M` | 窗口最大化 |
| `Mod` + `Ctrl` + `F` | 全屏 |
| `Mod` + `T` | 浮动 / 平铺切换 |
| `Mod` + `Ctrl` + `T` | 切换浮动 / 平铺焦点 |
| `Mod` + `W` | 标签页显示切换 |
| `Mod` + `O` | 窗口总览 |
| `Mod` + `Ctrl` + `O` | 恢复窗口不透明度 |
| `Mod` + `-` / `=` | 列宽 -5% / +5% |
| `Mod` + `Shift` + `-` / `=` | 窗口高度 -5% / +5% |
| `Mod` + `[` / `]` | 窗口靠左 / 靠右（并入列） |
| `Mod` + `Shift` + `A` | 添加窗口到列 |
| `Mod` + `.` / `Shift` + `D` | 从列中移除窗口 |

## 焦点切换

| 快捷键 | 功能 |
|--------|------|
| `Mod` + `←` / `→` | 左 / 右列焦点 |
| `Mod` + `↑` / `↓` | 上 / 下窗口焦点 |
| `Mod` + `Tab` | 下一个窗口（工作区内） |
| `Mod` + `Shift` + `Tab` | 上一个窗口 |
| `Mod` + `` ` `` | 下一个窗口（按应用过滤） |
| `Mod` + `Shift` + `` ` `` | 上一个窗口（按应用过滤） |

## 截图

| 快捷键 | 功能 |
|--------|------|
| `Mod` + `P` | 区域截图（存入 ~/Pictures/screenshots） |
| `Mod` + `Ctrl` + `P` | 全屏截图 |
| `Mod` + `Shift` + `P` | 窗口截图 |

## 系统与会话

| 快捷键 | 功能 |
|--------|------|
| `Mod` + `Alt` + `L` | 锁屏 |
| `Mod` + `Alt` + `X` | 会话菜单（关机 / 重启 / 注销） |
| `Mod` + `S` | 控制中心 |
| `Mod` + `,` | Noctalia 设置 |
| `Mod` + `Alt` + `W` | 壁纸切换 |
| `Mod` + `Shift` + `E` | 退出 Niri |
| `Mod` + `Esc` | 强制恢复 / 禁用 Niri 快捷键 |
| `XF86` 音量 / 亮度键 | 音量与亮度控制（Noctalia） |

## 窗口规则（自动行为）

- **最大化打开**：VSCode、Logisim、Brave、Zotero
- **浮动打开**：Fcitx5 配置、PicGo、btop、qView、LocalSend、微信、QQ、Telegram、Discord、欧陆词典、cc-switch
- **侧边浮动**：Pot（右侧 20% 宽长条）
- 全局默认平铺，圆角 3px
