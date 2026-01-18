# Nix 工具快速参考

## nix-index - 快速查找包

```bash
# 首次使用：生成索引
nix-index

# 查找命令
nix-locate fd
nix-locate --top-level ripgrep

# 自动每周更新（已配置）
systemctl --user status nix-index-update.timer
```

## nix-tree - 可视化依赖

```bash
# 查看包的依赖树
nix-tree nixpkgs.helix

# 交互式浏览
nix-tree
```

## nix-output-monitor - 美化输出

```bash
# 使用 nom 替代 nix
nom build
nom shell
nix build |& nom
```

## nixpkgs-unstable - 最新版本包

```nix
# 在 configuration.nix 中
{ config, lib, pkgs, nixpkgs-unstable, ... }:

let
  pkgs-unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  environment.systemPackages = with pkgs; [
    pkgs-unstable.helix  # 使用最新版本
  ];
}
```

## 临时使用 unstable

```bash
# 临时运行
nix run nixpkgs-unstable#hello

# 临时进入环境
nix shell nixpkgs-unstable#ripgrep

# 查找包
nix search nixpkgs-unstable package-name
```

## 常用命令速查

| 命令 | 说明 |
|------|------|
| `nix-index` | 生成包索引 |
| `nix-locate <cmd>` | 查找命令对应的包 |
| `nix-tree <pkg>` | 查看包的依赖树 |
| `nom build` | 美化构建输出 |
| `nix search nixpkgs <pkg>` | 搜索包 |
| `nix shell nixpkgs#<pkg>` | 临时使用包 |
| `nix run nixpkgs#<pkg>` | 运行包 |
| `nix flake update` | 更新 flake 输入 |

## 配置文件位置

- **系统配置**: `nixos/configuration.nix`
- **nix-index 服务**: `nixos/nix-index.nix`
- ** Flake 配置**: `flake.nix`

## 文档

- [unstable-packages.md](unstable-packages.md) - unstable 包使用指南
- [nix-index.md](nix-index.md) - nix-index 详细使用说明
- [package-management.md](package-management.md) - 高级包管理功能
