# nix-index 使用指南

## 什么是 nix-index？

`nix-index` 是一个强大的工具，可以快速查找 nixpkgs 中哪个包提供了特定的命令或文件。

## 安装

已在系统配置中安装 `nix-index`：

```nix
environment.systemPackages = with pkgs; [
  nix-index
];
```

## 首次使用

### 生成包索引

```bash
# 生成完整索引（需要几分钟，下载约 100MB 数据）
nix-index

# 或使用特定架构的索引
nix-index --index-url https://github.com/nix-community/nix-index-database
```

索引会保存到 `~/.cache/nix-index/`。

## 基本用法

### 查找命令

```bash
# 查找哪个包提供了 'fd' 命令
nix-locate fd

# 查找二进制文件
nix-locate -b python

# 仅显示包名
nix-locate --top-level fd

# 查找特定文件
nix-locate --type f --type x /bin/ls
```

### 示例输出

```bash
$ nix-locate fd
fd_8_0_0.out                               1,020H   x   /nix/store/...-fd-8.0.0/bin/fd
                                            1,020H   x   /nix/store/...-fd-8.0.0/bin/fd-find

$ nix-locate --top-level ripgrep
ripgrep_13_0_0.out                                     ripgrep
```

## 高级用法

### 结合管道使用

```bash
# 查找并过滤结果
nix-locate python | grep bin

# 查找多个命令
for cmd in fd rg bat; do
  echo "$cmd: $(nix-locate --top-level $cmd)"
done
```

### 在脚本中使用

```bash
#!/usr/bin/env bash
# 查找命令并提示安装

find_package() {
  local cmd=$1
  local pkg=$(nix-locate --top-level --type x --type f "/bin/$cmd" | head -n1)

  if [[ -n "$pkg" ]]; then
    echo "Command '$cmd' is provided by package: $pkg"
    echo "Install with: nix-shell -p $pkg"
  else
    echo "Command '$cmd' not found in nixpkgs"
  fi
}

find_package "$1"
```

## 集成到 Shell

### Fish 集成

创建 `~/.config/fish/conf.d/nix-index.fish`:

```fish
# nix-locate 别名
abbr -a nix-locate nix-locate

# 当命令未找到时，使用 nix-index 查找
function __fish_command_not_found_handler --description "Fallback to nix-index"
  set -l loc (command nix-locate --top-level --type x --type f "/bin/$argv[1]" 2>/dev/null | head -n1)

  if test -n "$loc"
    echo "The command '$argv[1]' is not installed, but available in nixpkgs."
    echo "You can install it with:"
    echo ""
    echo "  nix-shell -p $loc"
    echo "  # or temporarily:"
    echo "  nix shell nixpkgs#$loc"
    echo ""
    return 127
  end

  echo "fish: Unknown command: $argv[1]"
  return 127
end
```

### Bash 集成

添加到 `~bashrc`:

```bash
# command_not_found_handle 函数
command_not_found_handle() {
  local pkg=$(nix-locate --top-level --type x --type f "/bin/$1" 2>/dev/null | head -n1)

  if [[ -n "$pkg" ]]; then
    echo "The command '$1' is not installed, but available in package: $pkg"
    echo "Install with: nix-shell -p $pkg"
    return 127
  fi

  echo "bash: $1: command not found"
  return 127
}
```

## 自动更新

系统已配置自动更新服务：

```nix
# systemd user timer
systemd.user.timers.nix-index-update
```

手动更新：

```bash
# 重新生成索引
nix-index

# 检查定时器状态
systemctl --user status nix-index-update.timer
systemctl --user list-timers
```

## 常见用例

### 1. 找到需要的包并安装

```bash
# 查找命令
$ nix-locate terraform
terraform_1_5_7.out  terraform

# 安装包
nix-shell -p terraform

# 或永久安装（在配置中添加）
```

### 2. 比较不同版本的包

```bash
# 查看所有可用版本
nix-locate '^/bin/python3$'

# 使用 unstable 版本
nix-locate --index /path/to/unstable-index python3
```

### 3. 查找共享库

```bash
# 查找 .so 文件
nix-locate --type s --type f libssl.so

# 查找头文件
nix-locate --type f stdio.h
```

### 4. 在开发中查找依赖

```bash
# 查找构建工具
nix-locate cmake
nix-locate make

# 查找编译器
nix-locate gcc
nix-locate clang
```

## 性能优化

### 减小索引大小

```bash
# 只索引特定路径
nix-index --exclude '/nix/store/*-doc/*'
nix-index --exclude '/nix/store/*-man/*'
```

### 使用预构建索引

```bash
# 从 GitHub 下载预构建的索引
wget -P ~/.cache/nix-index \
  https://github.com/nix-community/nix-index-database/releases/latest/download/x86_64-linux-index

# 或使用 index-url 参数
nix-index --index-url https://github.com/nix-community/nix-index-database
```

## 故障排查

### 索引过期

```bash
# 重新生成索引
rm -rf ~/.cache/nix-index
nix-index
```

### 找不到包

```bash
# 更新 nixpkgs
nix-channel --update nixpkgs
nix-index

# 或使用 flake
nix flake update
```

### 权限问题

```bash
# 确保缓存目录可写
mkdir -p ~/.cache/nix-index
chmod 755 ~/.cache/nix-index
```

## 相关工具

### nix-tree

可视化 Nix 包的依赖树：

```bash
# 查看特定包的依赖
nix-tree nixpkgs.helix

# 交互式浏览
nix-tree
```

### nix-output-monitor

美化 Nix 构建输出：

```bash
# 使用 nom 替代 nix
nom build
nom shell
```

### nix-search

交互式搜索 nixpkgs：

```bash
# 搜索包
nix search nixpkgs python

# 使用 fzf 集成
nix-search | fzf
```

## 最佳实践

1. **定期更新索引** - 系统已配置每周自动更新
2. **使用别名** - 创建简短的别名提高效率
3. **结合补全** - 使用 `nix-locate` 创建命令补全
4. **脚本化** - 在脚本中使用 `nix-locate` 自动查找包

## 示例配置

### 完整的 Fish 集成

```fish
# ~/.config/fish/conf.d/nix-index.fish

# 缩写
abbr -a nl nix-locate

# 快速查找并安装
function nix-install
  set -l pkg (nix-locate --top-level --type x "/bin/$argv[1]" | head -n1)
  if test -n "$pkg"
    nix-shell -p $pkg
  else
    echo "Package not found for command: $argv[1]"
  end
end

abbr -a xi nix-install
```

## 相关资源

- [nix-index GitHub](https://github.com/nix-community/nix-index)
- [nix-index-database](https://github.com/nix-community/nix-index-database)
- [NixOS Manual - nix-index](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-locate.html)
