# 文档索引

`docs/` 放各子系统的深度说明；根 `AGENTS.md` 只留总规则。动某个子系统前先读对应那篇，能省一轮反推。

| 改动主题 | 文档 | 对应代码 |
|------|------|----------|
| 仓库结构、选项映射、module 分层、主机清单 | `docs/architecture.md` | `flake.nix`、`modules/`、`hosts/` |
| 平台适配坑位 / workaround / 待上游修复项 | `docs/quirks.md` | 各文件头部注释 |
| Fish、环境变量、PATH | `docs/fish.md` | `modules/home-manager/cli/shell/fish.nix` |
| Foot 终端 | `docs/foot.md` | `modules/home-manager/gui/apps/foot.nix` |
| 输入法（Rime、候选窗、托盘图标） | `docs/input.md` + `docs/themes.md` | `modules/home-manager/gui/fcitx5.nix`、`modules/nixos/desktop/default.nix` |
| 桌面主题 / GTK / Qt / 图标 / 壁纸 | `docs/themes.md` | `modules/home-manager/gui/themes/default.nix`、`modules/home-manager/gui/wm/noctalia.nix` |
| Niri 快捷键、窗口与布局规则 | `docs/niri.md` | `modules/home-manager/gui/wm/config/` + 生成 KDL 的 `gui/wm/default.nix` |
| GNOME（laptop 也装了，但默认会话是 Niri） | `docs/gnome.md` | `modules/nixos/desktop/gnome/default.nix` |
| 装了哪些应用 | `docs/softwares.md` | `modules/home-manager/gui/apps/`（含嵌入式工具链） |
| 开发工具链、Distrobox | `docs/environment.md` | `modules/home-manager/cli/dev` |
| tmux（含会话持久化） | `docs/tmux.md` | `modules/home-manager/cli/tools/tmux.nix` + `tests/tmux-persistence.sh` |
| WinApps / Windows 虚拟机 / 探针直通 | `docs/winapps.md` | `modules/home-manager/gui/winapps.nix`、`pkgs/windows-vm-media`、`modules/nixos/virtualization` |
| 部署、升级、垃圾回收 | `docs/manager.md` | 部署 / 升级 / GC 命令速查 |
