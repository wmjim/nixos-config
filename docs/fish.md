# Fish Shell

配置位置：`modules/home-manager/cli/shell/fish.nix`。

终端默认英文环境，`EDITOR=nvim`，`LC_ALL=en_US.UTF-8`。

## 系统部署别名

| 别名 | 功能 |
|------|--------|
| `updatedp` | 重建 desktop 主机 |
| `updatedplog` | 重建 desktop 并输出详细构建日志 |
| `updatelp` | 重建 laptop 主机 |
| `updatelplog` | 重建 laptop 并输出详细构建日志 |
| `updatewsl` | 重建 WSL 主机 |

## 文件与目录

`ls` / `ll` / `la` / `lla` / `lt` 的参数（icons / colors / git / 排序）来自 `programs.eza`，
配置在 `modules/home-manager/cli/shell/default.nix`。模块生成的别名体调 `eza`，参数挂在
`eza` 这条别名上，所以改参数去那里，不要在 `fish.nix` 重写整条别名。

| 别名 | 功能 |
|------|--------|
| `..` / `...` | 上级 / 上上级目录 |
| `ls` / `ll` / `la` / `lla` | eza 增强列表 |
| `lt` | 目录树 |
| `cat` | bat 分页显示 |

## Git

| 别名 | 功能 |
|------|--------|
| `gs` | git status |
| `ga` | git add |
| `gc` | git commit |
| `gp` | git push |
| `gl` | git log 图形化 |

## 磁盘

| 别名 | 功能 |
|------|--------|
| `df` | duf 仅本地磁盘 |
| `duf` | duf 按用量排序 |
| `dufall` | duf 全部磁盘 |
| `dufjson` | duf JSON 输出 |

## 其他

| 别名 / 命令 | 功能 |
|------|--------|
| `cc` | Claude Code（跳过权限确认） |
| `arch` / `ubuntu` | distrobox 进入对应发行版容器 |
| `zquery` | zoxide 查询历史目录 |
| `Ctrl` + `o` | 命令选择器（fzf 模糊选择常用命令） |
| `cheat <provider>` | 快捷键速查表（fish / tmux / vim） |
| `lg` | lazygit（由 `programs.lazygit` 的 fish 集成提供，退出时 `cd` 到刚才操作过的目录） |
