# CLAUDE.md

该文件用于为 Claude Code（claude.ai/code）提供指引，方便其处理本代码仓库内的代码。

## 命令

```bash
# 部署主机配置
sudo nixos-rebuild switch --flake ~/nixos-config#desktop
sudo nixos-rebuild switch --flake ~/nixos-config#laptop
sudo nixos-rebuild switch --flake ~/nixos-config#wsl

# 详细构建日志 (用于排错调试)
sudo nixos-rebuild switch --flake ~/nixos-config#desktop --show-trace --print-build-logs --verbose

# 格式化所有 Nix 文件
nix fmt                    # uses nixpkgs-fmt

# 更新 flake 锁定文件
nix flake update
nix flake update <input>   # update a single input

# 垃圾回收，清理旧版本系统
sudo nix-collect-garbage --delete-old

# 进入开发环境 (git + nixpkgs-fmt)
nix develop
```

## 架构

### 基于选项的主机配置 (`mySystem` 命名空间)

无需为每台主机单独导入模块，所有功能模块都由 `core/default.nix` 无条件导入，再通过选项开关控制是否生效。选项**就近定义在各自功能模块中**，只有三个顶层域开关集中在 `core/default.nix`：

```nix
options.mySystem = {
  hardware.enable = ...;
  desktop.enable = ...;
  virtualization.enable = ...;
};
```

各模块通过 `lib.mkIf config.mySystem.<foo>.enable` 实现条件启用。新增功能时，选项应定义在实现该功能的模块文件里（而非集中到 core），再在对应域的聚合模块中用 `lib.mkDefault` 给出默认开关值。

### 选项 → 文件映射

| 选项 | 定义位置 | 说明 |
|------|----------|------|
| `mySystem.hardware.enable` | `modules/nixos/core/default.nix` | 顶层域开关，开启后默认连带启用下列 hardware 子选项 |
| `mySystem.desktop.enable` | `modules/nixos/core/default.nix` | 顶层域开关 |
| `mySystem.virtualization.enable` | `modules/nixos/core/default.nix` | 顶层域开关（QEMU/KVM） |
| `mySystem.users.<name>.{enable,extraGroups,shell}` | `modules/nixos/core/users.nix` | 用户声明，主机配置中覆盖 |
| `mySystem.proxy.{enable,port,extraNoProxy}` | `modules/nixos/networking/proxy.nix` | 本机 HTTP 代理（Clash Verge） |
| `mySystem.hardware.audio.enable` | `modules/nixos/hardware/audio.nix` | PipeWire |
| `mySystem.hardware.bluetooth.enable` | `modules/nixos/hardware/bluetooth.nix` | |
| `mySystem.hardware.network.enable` | `modules/nixos/hardware/network.nix` | iwd + NetworkManager |
| `mySystem.hardware.mcu.enable` | `modules/nixos/hardware/mcu.nix` | 嵌入式开发工具链 |
| `mySystem.hardware.nvidia.enable` | `modules/nixos/hardware/nvidia-base.nix` | 需主机显式开启（server/WSL 不需要） |
| `mySystem.desktop.niri.enable` | `modules/nixos/desktop/default.nix` | Niri WM |
| `mySystem.desktop.gnome.enable` | `modules/nixos/desktop/default.nix` | GNOME |
| `mySystem.desktop.scale` | `modules/nixos/desktop/default.nix` | 分数缩放，AWT 应用会向上取整 |
| `mySystem.desktop.distrobox.enable` | `modules/nixos/desktop/distrobox.nix` | |
| `mySystem.desktop.steam.enable` | `modules/nixos/desktop/steam.nix` | |

### Module layering

```
modules/
  nixos/core/       在所有NixOS主机中永久导入：用户配置、区域语言、硬件适配、桌面环境、虚拟化、网络组件
  nixos/desktop/    永久导入，由mySystem.desktop.enable控制生效：boot、GDM、env、Niri、GNOME、Distrobox、Steam
  nixos/hardware/   永久导入，由mySystem.hardware.enable控制生效：音频（PipeWire）、蓝牙、网络（iwd+NetworkManager）、MCU工具链、NVIDIA基础驱动（后者需显式开启）
  home-manager/     多用户共用配置，同时兼容 NixOS 与 macOS 系统
    cli/            通用加载项：Shell（Fish）、编辑器（Helix / Neovim）、开发工具、TUI终端交互工具
    gui/            仅用于桌面用户加载：应用程序、备用主题、窗口管理器（Niri / Noctalia）、VSCode、Fcitx5输入法
  darwin/           macOS专属配置：系统默认设置、Homebrew图形化应用包
```

### `mkHomeManager` 样板代码

`flake.nix` 中定义了 `mkHomeManager` 函数，用于生成所有 NixOS 主机共用的 Home-Manager 集成配置块。带图形界面的主机传入参数 `extraModules = [ ./modules/home-manager/gui ]`；无图形服务器主机与 WSL 环境主机则不传入该参数。macOS 系统使用独立的内联 Home-Manager 配置块（不调用 `mkHomeManager`），原因是其需要通过 `lib.mkForce` 强制覆盖 NUR 软件源覆盖层，且共用模块的配置逻辑与 NixOS 不同。

### 各主机配置

| Host | System | Key features |
|------|--------|-------------|
| desktop | x86_64-linux | Niri WM, NVIDIA RTX 3060Ti, 4K@150Hz, custom EDID firmware |
| laptop | x86_64-linux | GNOME, NVIDIA MX150 (legacy driver, PRIME offload), btrfs, TLP |
| wsl | x86_64-linux | CLI-only, WSL container |
| server | x86_64-linux | Stub, only nixosCore |
| macbook | aarch64-darwin | nix-darwin, Homebrew casks |

### 平台适配特殊处理

- **国内清华镜像源**：二进制替换源与 nixpkgs 源码均使用 `mirrors.tuna.tsinghua.edu.cn`。若身处境外，下载速度会偏慢，可自行更换镜像。
- **Fish 4.8.0 覆盖补丁**：`modules/home-manager/default.nix` 对 Fish 打补丁，补全缺失的 `create_manpage_completions.py` 文件（对应 nixpkgs 工单 #535122）。待上游合并修复后即可移除该覆盖层。
- **NVIDIA 显存泄漏修复**：`modules/nixos/hardware/nvidia-base.nix` 配置 Niri 应用专属参数，限制空闲缓冲区池大小，规避显存泄漏问题。
- **自动升级固定走 flake**：`system.autoUpgrade.flake` 由 `networking.hostName` 推导出 `/home/mengw/nixos-config#<host>`。新增主机时 `networking.hostName` 必须与 flake 输出属性同名，否则 autoUpgrade 会找错目标。`allowReboot = false` 意味着内核更新后**不会自动重启**，需手动重启才能用上新内核。各主机的 flake 仓库统一位于 `/home/mengw/nixos-config`，若某主机仓库路径不同需覆盖该选项。
