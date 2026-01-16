# Yazi 文件管理器使用指南

[Yazi](https://github.com/sxyazi/yazi) 是一个用 Rust 编写的现代化终端文件管理器，速度快、功能强大。

## 目录

- [安装](#安装)
- [基础使用](#基础使用)
- [快捷键](#快捷键)
- [主题定制](#主题定制)
- [高级配置](#高级配置)

## 安装

Yazi 已经通过 Home Manager 自动安装。配置文件位于：

- **主配置**: `~/.config/yazi/yazi.toml`
- **主题配置**: `~/.config/yazi/theme.toml`
- **快捷键配置**: `~/.config/yazi/keymap.toml`

## 基础使用

### 启动 Yazi

```bash
# 使用 yy 函数启动（推荐，退出后自动切换目录）
yy

# 或直接启动
yazi

# 在指定目录启动
yy /path/to/directory

yazi /path/to/directory
```

### 基本操作

| 操作 | 按键 | 说明 |
|------|------|------|
| 退出 | `q` | 退出 yazi |
| 退出但不切换目录 | `Q` | 退出但不改变当前目录 |
| 进入目录/打开文件 | `Enter` | 进入目录或打开文件 |
| 返回上级目录 | `[` | 返回上一级目录 |
| 返回根目录 | `~` | 跳转到根目录 |
| 切换隐藏文件 | `.` | 显示/隐藏隐藏文件 |

### 文件操作

| 操作 | 按键 | 说明 |
|------|------|------|
| 选择文件 | `Space` | 选择/取消选择当前文件 |
| 全选 | `V` | 全选所有文件 |
| 反选 | `v` | 反向选择所有文件 |
| 取消选择 | `Esc` | 取消所有选择 |
| 复制 | `y` | 复制选中的文件 |
| 剪切 | `x` | 剪切选中的文件 |
| 粘贴 | `p` | 粘贴文件/目录 |
| 删除 | `d` | 删除选中的文件 |
| 重命名 | `r` | 重命名当前文件 |
| 创建 | `a` | 创建新文件/目录 |
| 打开 | `e` | 用编辑器打开文件 |

### 搜索

| 操作 | 按键 | 说明 |
|------|------|------|
| 搜索 | `/` | 搜索文件名 |
| 下一个结果 | `n` | 跳转到下一个搜索结果 |
| 上一个结果 | `N` | 跳转到上一个搜索结果 |
| 跳转 | `z` | 跳转到指定目录 |

## 快捷键完整列表

### 导航

| 按键 | 功能 | 说明 |
|------|------|------|
| `[` | 返回上级目录 | 向上一级目录 |
| `]` | 进入子目录 | 进入子目录 |
| `~` | 回到主目录 | 跳转到用户主目录 |
| `z` | 跳转 | 跳转到指定目录 |
| `-` | 跳转到根目录 | 跳转到文件系统根目录 |
| `_` | 跳转到底部 | 跳转到底部目录 |

### 选择操作

| 按键 | 功能 | 说明 |
|------|------|------|
| `Space` | 选择/取消选择 | 切换当前文件的选择状态 |
| `v` | 全选 | 选择所有文件 |
| `V` | 反选 | 反向选择所有文件 |
| `d` | 删除 | 删除选中的文件 |

### 文件操作

| 按键 | 功能 | 说明 |
|------|------|------|
| `y` | 复制 | 复制选中的文件 |
| `x` | 剪切 | 帘切选中的文件 |
| `p` | 粘贴 | 粘贴文件/目录 |
| `a` | 创建 | 创建新文件或目录 |
| `r` | 重命名 | 重命名当前文件或目录 |

### 系统操作

| �按键 | 功能 | 说明 |
|------|------|------|
| `q` | 退出 | 退出 yazi（保留当前目录） |
| `Q` | 退出不切换目录 | 退出但不改变当前 shell 目录 |
| `e` | 打开 | 用编辑器打开文件 |
| `:` | Shell | 在当前目录打开 shell |
| `Esc` | 取消 | 取消当前操作 |

### 搜索

| 按键 | 功能 | 说明 |
|------|------|------|
| `/` | 搜索 | 搜索文件 |
| `n` | 下一个结果 | 跳转到下一个搜索结果 |
| `N` | 上一个结果 | 跳转到上一个搜索结果 |

## 主题定制

Yazi 使用 Catppuccin Frappe 主题，配色方案：

### 颜色定义

```
基础色：#303446  (背景)
文本色：#c6d0f5
蓝色：#8caaee
绿色：#a6d189
黄色：#e5c890
红色：#e78284
```

### 主题文件位置

主题配置位于 `~/.config/yazi/theme.toml`，包含：

- **目录样式**: 当前目录、文件、选中状态
- **状态栏**: 不同模式（正常、选择、未设置）
- **权限颜色**: rwx 权限颜色
- **文件类型**: 不同文件类型的颜色编码
  - 图片：紫色 (#ca9ee6)
  - 视频：橙色 (#ef9f76)
  - 压缩包：粉红色 (#f4b8e4)
  - PDF：红色 (#e78284)
  - 代码：黄色 (#e5c890) / 蓝色 (#8caaee)
  - 配置文件：深色主题

## 高级配置

### 自定义文件类型颜色

编辑 `~/.config/yazi/theme.toml`：

```toml
[filetype]
rules = [
	# 根据扩展名自定义颜色
	{ name = "*.myext", fg = "#custom_color" },

	# 根据 MIME 类型自定义颜色
	{ mime = "application/mytype", fg = "#custom_color" },
]
```

### 自定义快捷键

编辑 `~/.config/yazi/keymap.toml`：

```toml
keymap = [
	# 添加新的快捷键
	{ on = [";"], run = "shell 'git status'", desc = "Git status" },
	{ on = ["P"], run = "shell 'git push'", desc = "Git push" },

	# 覆盖默认快捷键
	{ on = ["o"], run = "open", desc = "Open with default app" },
]
```

### 自定义打开方式

编辑 `~/.config/yazi/yazi.toml`：

```toml
[opener]
open = [
	# 默认打开方式
	{ run = "xdg-open \"$1\"", desc = "Open" },
	# 右键菜单中的额外选项
	{ run = "code \"$1\"", desc = "Open with VS Code" },
]

# 为特定类型定义打开方式
[open]
rules = [
	{ name = "*.md", use = [ "edit", "open" ] },
	{ name = "*.toml", use = [ "edit", "open" ] },
]
```

## WSL 优化

### 浏览器集成

在 WSL 中，yazi 已经配置了浏览器集成：

```toml
[opener]
open = [
	{ run = "wslview \"$1\"", desc = "Open with wslview", for = "linux" },
]
```

### Windows 路径别名

在 `~/.config/fish/config.fish` 中已添加：

```fish
alias winhome='cd /mnt/c/Users/$USER'
```

快速访问 Windows 文件：
```bash
winhome  # 跳转到 Windows 用户主目录
```

## 使用技巧

### 1. 快速切换目录

使用 `yy` 函数：
- 在 yazi 中浏览到目标目录
- 退出 yazi
- 自动切换到该目录

### 2. 搜索文件

1. 按 `/` 进入搜索模式
2. 输入文件名（支持模糊匹配）
3. 按 `Enter` 跳转到第一个结果
4. 使用 `n` 和 `N` 在结果中导航

### 3. 批量操作

- **选择多个文件**：
  - 按 `v` 全选
  - 按 `Space` 切换特定文件
  - 按 `V` 反选

- **批量操作**：
  - 选择文件后按 `y` 复制
  - 导航到目标目录
  - 按 `p` 粘贴

### 4. 预览文件

- **图片**：自动显示缩略图
- **视频**：显示第一帧
- **代码**：语法高亮显示
- **PDF**：显示首页

### 5. 使用 Shell 命令

按 `:` 进入 shell 模式：
- 在当前目录执行命令
- 退出 shell 后返回 yazi

## 常见使用场景

### 场景 1：快速导航

```bash
# 启动 yazi
yy

# 按 z 跳转
# 输入目录名（支持模糊匹配）
# 按 Enter 进入
```

### 场景 2：批量复制

```bash
yy
# 按 v 全选（或 Space 切换）
# 按 y 复制
# 导航到目标目录
# 按 p 粘贴
```

### 场景 3：重命名

```bash
yy
# 选中文件
# 按 r 重命名
# 编辑名称
# 按 Enter 确认
```

### 场景 4：搜索并打开

```bash
yy
# 按 / 搜索
# 输入关键词（如 "config"）
# 按 Enter 跳转
# 按 e 在编辑器中打开
```

## 故障排除

### yazi 无法启动

```bash
# 检查 yazi 是否安装
which yazi

# 检查配置文件
ls ~/.config/yazi/

# 查看 yazi 版本
yazi --version
```

### 主题未生效

```bash
# 检查主题文件
cat ~/.config/yazi/theme.toml

# 重新加载配置
home-manager switch --flake .#mengw@wsl
```

### 快捷键冲突

编辑 `~/.config/yazi/keymap.toml` 移除冲突的快捷键。

## 参考资源

- [Yazi 官方文档](https://yazi-rs.github.io/docs/)
- [Yazi GitHub](https://github.com/sxyazi/yazi)
- [Yazi 配置示例](https://github.com/sxyazi/yazi/tree/main/config)
- [Catppuccin Yazi 主题](https://github.com/catppuccin/yazi)

## 更新日志

- **2025-01-17**：初始配置，包含 Catppuccin Frappe 主题
