# 架构速查

面向 Agent 与人的仓库地图：仓库结构、选项与 module 分层约定、主机差异。
改配置前先看这里；某个子系统的细节见 `docs/README.md` 的索引。

## 仓库结构

```text
flake.nix / flake.lock      # 唯一入口：inputs + 各主机输出 + overlays/packages/checks + devShell/formatter
├─ lib/                     # 跨模块共享函数（wrapQtXWayland）与平台枚举（forAllSystems）
├─ hosts/<host>/            # 每台主机 = 声明文件 + nixos-generate-config 产物；只放该主机的差异
├─ modules/nixos/           # NixOS 系统层：core / desktop / hardware / networking / virtualization
├─ modules/home-manager/    # 用户层：cli（跨平台）+ gui（仅桌面主机导入）
├─ modules/darwin/          # macOS 系统层：base / users / gui
├─ overlays/ + pkgs/        # 自维护包的单一注入点与包本体
├─ docs/                    # 子系统深度说明，索引见 docs/README.md
└─ .github/workflows/       # flake-check（eval + dry-build + niri validate）、flakehub-publish
```

编辑之前：
1. 检查 `flake.nix`
2. 确认目标 `nixosConfiguration`
3. 检查相关主机配置
4. 在添加新配置之前，先搜索现有的模块/选项。

## 选项约定

没有「按主机挑模块导入」这条路：所有功能模块都由 `core/default.nix` 无条件导入，
再由 `mySystem.<foo>.enable` 决定是否生效。

- 选项**就近定义在实现该功能的模块里**，不集中到 core。
- 每个域的**聚合模块**（`hardware/default.nix`、`desktop/default.nix`）用 `lib.mkDefault`
  给出该域的默认开关组合，主机文件因此只写**例外**（关单项用 `lib.mkForce`）。
- 主机数据（如 `mySystem.desktop.monitors`）留在 `hosts/`；共享模块只做生成器与消费方。
- 定义在 `core/` 的只有三个顶层域开关（`hardware`/`desktop`/`virtualization.enable`）
  与 `mySystem.primaryUser`——其余都在各自功能模块里。

**选项清单不在文档里维护**：`rg 'mkEnableOption|mkOption' modules/` 是唯一权威。
手抄的表一定会漂，所以这里没有它。

## 主机差异

| Host | System | 相对其它主机的差异 |
|------|--------|-------------------|
| desktop | x86_64-linux | 多 `desktop.steam.enable`；i2c（DDC 调光）+ EDID 冷启动自愈补丁；RTX 3060Ti，4K@150Hz |
| laptop | x86_64-linux | 内屏 1080p；额外 libvirt TPM2 凭证解密修复；MX150（legacy 驱动，PRIME offload），btrfs，TLP |
| wsl | x86_64-linux | CLI-only，`boot.isContainer`，额外 WSL2 代理地址探测（`hosts/wsl/proxy.nix`） |
| macbook | aarch64-darwin | nix-darwin，Homebrew casks |

两台桌面主机是**同一款配置的两个尺寸**：桌面能力（niri / gnome / distrobox /
virtualization / proxy）由 `desktop.enable` 的聚合默认值给出，主机文件里只留硬件数据
与真正的差异。

## Overlay 与自定义包

`overlays/default.nix` 是 `pkgs/` 自维护包的单一注入点，三处消费同一份清单：

- NixOS 系统级：`modules/nixos/core` 的 `nixpkgs.overlays`
- macOS 系统级：`modules/darwin/base` 的 `nixpkgs.overlays`
- flake 输出：`overlays.default` 与 `packages.*`（`nix flake check` 会逐一评估，
  nixpkgs 滚动带来的包级回归在 CI 即暴露）

Home Manager 走 `useGlobalPkgs = true` 复用系统级实例，不单独注入 overlay。

## Home Manager 接线

`flake.nix` 的 `mkHomeManager` 是 NixOS 与 darwin **共用的唯一一份**接线：

- `useGlobalPkgs = true`，用户名从宿主的 primaryUser 选项派生——NixOS 取
  `mySystem.primaryUser`，darwin 取 nix-darwin 的 `system.primaryUser`（由
  `mkHomeManager` 的 `primaryUser` 参数指定）。
- 桌面主机额外传 `extraModules = [ ./modules/home-manager/gui ]`，CLI-only 主机不传。
