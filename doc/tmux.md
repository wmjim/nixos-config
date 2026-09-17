# Tmux 终端复用器

配置位置：`modules/home-manager/cli/tools/tmux.nix` + `tmux/tmux.conf`（取自 Omarchy，无插件）。

前缀键：`Ctrl` + `b`。无前缀的 `Alt` / `Ctrl`+`Alt` 组合可直接操作窗口与面板，无需先按前缀。

## 面板 (Pane)

| 按键 | 功能 |
| --- | --- |
| `Prefix` + `h` / `Alt` + `Enter` | 上下分割 |
| `Prefix` + `v` / `Alt` + `Shift` + `Enter` | 左右分割 |
| `Prefix` + `x` / `Alt` + `Esc` | 关闭当前面板 |
| `Ctrl` + `Alt` + `←/→/↑/↓` | 左 / 右 / 上 / 下 切换面板焦点 |
| `Ctrl` + `Alt` + `Shift` + `←/→/↑/↓` | 左 / 右 / 上 / 下 调整面板大小（步进 5） |

## 窗口 (Window)

| 按键 | 功能 |
| --- | --- |
| `Prefix` + `c` | 新建窗口（继承当前路径） |
| `Prefix` + `r` | 重命名窗口 |
| `Prefix` + `k` | 关闭窗口 |
| `Alt` + `1`…`9` | 切换到第 N 个窗口 |
| `Alt` + `←` / `→` | 上一个 / 下一个窗口 |
| `Alt` + `Shift` + `←` / `→` | 向左 / 向右移动窗口 |

## 会话 (Session)

| 按键 | 功能 |
| --- | --- |
| `Prefix` + `C` | 新建会话 |
| `Prefix` + `R` | 重命名会话 |
| `Prefix` + `K` | 关闭会话 |
| `Prefix` + `P` / `N` | 上一个 / 下一个会话 |
| `Alt` + `↑` / `↓` | 上一个 / 下一个会话 |
| `Prefix` + `d` | 分离（detach）当前会话 |

## 复制模式

| 按键 | 功能 |
| --- | --- |
| `Prefix` + `[` | 进入复制模式 |
| `v` | 开始选择 |
| `y` | 复制并退出 |

## 其他

| 按键 | 功能 |
| --- | --- |
| `Prefix` + `q` | 重载配置 |
| `Prefix` + `?` | 弹出全部快捷键列表 |
| `Prefix` + `z` | 最大化 / 还原当前面板 |

重新连接会话：`tmux attach -t <会话名>`（或 `tmux ls` 查看后附加）。
