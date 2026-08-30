# 系统管理

## 部署新配置

```bash
# desktop 主机（Niri 桌面）
sudo nixos-rebuild switch --flake ~/nixos-config#desktop

# laptop 主机（GNOME 桌面）
sudo nixos-rebuild switch --flake ~/nixos-config#laptop

# WSL
sudo nixos-rebuild switch --flake ~/nixos-config#wsl

# 服务器
sudo nixos-rebuild switch --flake ~/nixos-config#server

# macOS
darwin-rebuild switch --flake ~/nixos-config#macbook
```

部署成功后会生成新系统环境，旧环境保留并加入 systemd-boot 启动项（最多保留 10 个，见 `boot.loader.systemd-boot.configurationLimit`）。

> Fish 别名：`updatedp` / `updatedplog` / `updatelp` / `updatelplog` / `updatewsl`

## 排错

```bash
# 构建时输出详细日志
sudo nixos-rebuild switch --flake ~/nixos-config#desktop --show-trace --print-build-logs --verbose
```

## 更新 flake 锁定文件

```bash
nix flake update          # 更新所有输入
nix flake update nixpkgs  # 只更新单个输入
```

## 查看与清理历史数据

```bash
# 查询当前可用所有历史版本
nix profile history --profile /nix/var/nix/profiles/system

# 清理 7 天之前的所有历史版本
sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system

# 删除所有未使用的包
sudo nix-collect-garbage --delete-old

# 存储优化
nix store optimise
```

> 系统已配置自动每周 GC（`--delete-older-than 7d`）与自动升级（`system.autoUpgrade`）。

## 其他常用命令

```bash
# 格式化所有 Nix 文件（nixpkgs-fmt）
nix fmt

# 进入开发环境（git + nixpkgs-fmt）
nix develop
```
