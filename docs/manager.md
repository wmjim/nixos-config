# 系统管理

## 部署新配置

```bash
# desktop 主机（Niri 桌面）
sudo nixos-rebuild switch --flake ~/Projects/nixos-config#desktop

# laptop 主机（GNOME 桌面）
sudo nixos-rebuild switch --flake ~/Projects/nixos-config#laptop

# WSL
sudo nixos-rebuild switch --flake ~/Projects/nixos-config#wsl

# macOS
darwin-rebuild switch --flake ~/Projects/nixos-config#macbook
```

部署成功后会生成新系统环境，旧环境保留并加入 systemd-boot 启动项（最多保留 10 个，见 `boot.loader.systemd-boot.configurationLimit`）。

> Fish 别名：`updatedp` / `updatedplog` / `updatelp` / `updatelplog` / `updatewsl`

## 装机后的一次性步骤

有一类状态由 Noctalia 自己持有（`~/.local/state/noctalia/settings.toml`）且**运行时覆盖 Nix 声明**，`switch` 不会替你改。新机器上跑一次，已经跑过的不必重复：

```bash
# 壁纸：把所有输出与 wallpaper.default.path 一起写进 settings.toml
noctalia msg wallpaper-set ~/Pictures/wallpaper/默认集/city-street.jpg

# 调色板：让 theme.source 真正生效（改后也可在 Noctalia 外观面板选一次）
noctalia msg color-scheme-set custom mactahoe
noctalia msg color-scheme-get   # 应回：custom mactahoe
```

bar 的布局也只能在 GUI 里点（那些键在 `settings.toml` 里，会覆盖 Nix 声明）：`background_opacity` → **0.30**；`end` 留 tray / clipboard / notifications / volume / brightness / session；`center` 只留 date；`start` 只留 workspaces；cat 的 `rave_mode` 关掉。数值与算据见 `docs/themes.md` 的「bar 收敛」。

## 排错

```bash
# 构建时输出详细日志
sudo nixos-rebuild switch --flake ~/Projects/nixos-config#desktop --show-trace --print-build-logs --verbose
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
# 格式化所有 Nix 文件（nixfmt，RFC 166 风格；裸调用即递归格式化全树）
nix fmt

# 只格式化指定文件
nix fmt path/to/file.nix

# 进入开发环境（git + treefmt/nixfmt）
nix develop
```
