# 软件方案

所有应用由 Home Manager 统一管理（`modules/home-manager/gui/apps/`）。

## 桌面环境

| 组件 | 软件 |
|------|------|
| 窗口管理器（desktop） | [Niri](https://github.com/YaLTeR/niri) - Wayland 平铺合成器 |
| 桌面环境（laptop 默认） | GNOME |
| Shell（桌面外壳） | [Noctalia](https://github.com/noctalia-dev/noctalia-shell) - 启动器 / 控制中心 / 壁纸 / 锁屏 |
| 显示管理器 | GDM |
| 输入法 | Fcitx5 + Rime（万象拼音） |

## 终端

| 组件 | 软件 |
|------|------|
| 终端模拟器 | Alacritty（Catppuccin Frappe 主题） |
| Shell | Fish（含大量自定义别名） |
| 终端复用器 | Zellij |
| 终端文件管理器 | Yazi（`y`） |

## 浏览器与通讯

| 类别 | 软件 |
|------|------|
| 浏览器 | Zen Browser（默认）、Brave |
| 通讯 | Discord、Telegram、微信（XWayland 适配）、QQ |

## 开发工具

| 类别 | 软件 |
|------|------|
| 编辑器 | Helix、VSCode（含 Claude Code / Nix / Python / Rust / Docker 等扩展）、Zed |
| IDE | JetBrains：PyCharm / CLion / IntelliJ / Rider / DataGrip |
| AI 编程 | Claude Code、pi-coding-agent |
| Git | git、lazygit、github-desktop |
| 容器 | Distrobox + Podman、Docker 扩展、lazydocker |

## 生产力与笔记

| 软件 | 用途 |
|------|------|
| Obsidian / 思源笔记 | 笔记 |
| Typora | Markdown 写作 |
| Zotero | 文献管理 |
| Anki | 记忆卡片 |
| XMind | 思维导图 |
| Thunderbird | 邮件 |
| Pot | 划词翻译（Alt+T / Alt+I / Alt+X） |

## 媒体与工具

| 软件 | 用途 |
|------|------|
| VLC / Freetube / gapless / parabolic | 视频 / 音乐 / 下载（yt-dlp 前端） |
| OBS Studio | 录屏 / 直播 |
| PicGo + snipaste | 截图与图床上传 |
| Mission Center / btop / fastfetch | 系统监控 |
| ddcutil（配合 Noctalia） | 显示器亮度控制 |
| qView / Papers / Foliate / Wike | 看图 / PDF / 电子书 / Wiki |
| LocalSend | 局域网文件传输 |
| 欧陆词典 | 查词 |
| 迅雷（xunlei-uos） | 下载 |
| Logisim Evolution | 数字电路模拟 |
| file-roller / Nautilus | 压缩 / 文件管理 |

## 游戏

| 软件 | 用途 |
|------|------|
| Steam | 游戏平台（desktop 主机） |
| MangoHud | 性能监控（游戏启动项：`mangohud %command%`） |
| GameMode | 提频（`gamemoderun %command%`） |
| Gamescope | 独立合成器（`gamescope -- <app>`） |
| steamguard-cli | Steam 2FA 验证码 |

## 系统工具（CLI）

eza、zoxide、bat、fzf、ripgrep、fd、jq、yq、tldr、duf、btop、glow、hugo、ffmpeg、yt-dlp、net-tools、tree、unzip、sysstat

## 字体

| 字体 | 用途 |
|------|------|
| Maple Mono NF（CN） | 等宽 / 代码 |
| HarmonyOS Sans SC | 界面无衬线 |
| LXGW WenKai（霞鹜文楷） | 中文衬线阅读 |
| Noto Sans/Serif CJK SC | 中文回退兜底 |
| Noto Color Emoji | Emoji |
