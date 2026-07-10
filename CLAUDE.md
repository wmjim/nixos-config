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

无需为每台主机单独导入模块，`modules/nixos/core/default.nix` 定义了一个选项命名空间：

```nix
options.mySystem = {
  hardware.enable = ...;
  desktop.enable = ...;
  virtualization.enable = ...;
};
```

`hosts/` 目录下的每台主机配置都会设置这类布尔开关。各模块通过 `lib.mkIf config.mySystem.<foo>.enable` 实现条件启用。新增功能需遵循该规范：先在 `core/default.nix` 中添加对应配置项，用该配置项控制模块加载，最后在主机配置里开启开关。

### Module layering

```
modules/
  nixos/core/       在所有NixOS主机中永久导入：用户配置、区域语言、Stylix主题、硬件适配、桌面环境、虚拟化、网络组件
  nixos/desktop/    由mySystem.desktop.enable开关控制加载：boot、GDM、env、Niri、GNOME、Distrobox
  nixos/hardware/   由mySystem.hardware.enable开关控制加载：音频（PipeWire）、蓝牙、网络（iwd+NetworkManager）、NVIDIA基础驱动
  home-manager/     多用户共用配置，同时兼容 NixOS 与 macOS 系统
    cli/            通用加载项：Shell（Fish + Starship）、编辑器（Helix / Neovim）、开发工具、TUI终端交互工具
    gui/            仅用于桌面用户加载：应用程序、备用主题、窗口管理器（Niri / Noctalia）、VSCode、Fcitx5输入法
  darwin/           macOS专属配置：系统默认设置、Homebrew图形化应用包
```

### `mkHomeManager` 样板代码

`flake.nix` 中定义了 `mkHomeManager` 函数，用于生成所有 NixOS 主机共用的 Home-Manager 集成配置块。带图形界面的主机传入参数 `extraModules = [ ./modules/home-manager/gui ]`；无图形服务器主机与 WSL 环境主机则不传入该参数。macOS 系统使用独立的内联 Home-Manager 配置块（不调用 `mkHomeManager`），原因是其需要通过 `lib.mkForce` 强制覆盖 NUR 软件源覆盖层，且共用模块的配置逻辑与 NixOS 不同。

### Stylix theming

主题在 `modules/nixos/core/stylix.nix` 文件内联定义，包含四套自定义 Base16 配色方案：aurora-dark、claude-light、macos-light、macos-dark。主机通过 `mySystem.stylix.theme` 配置项选择所用主题。部分 Stylix 适配目标被主动禁用：

- `fish`：Base16 色彩命令会覆盖终端主题
- `zen-browser`：自带独立主题管理
- `vscode`：自带独立主题管理

Niri 窗口管理器的配色在构建阶段由 Stylix 生成，并通过 `home.activation.niriStylixColors` 写入 `layout.kdl` 与 `overview.kdl` 配置文件。

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
- **关闭 Stylix 版本校验**：Stylix 跟随不稳定分支，而 Home Manager 基于 release-26.05 稳定分支，因此必须禁用版本校验。
- **cuda-maintainers 缓存源**：构建 NVIDIA 驱动时启用该缓存，需提前信任其公钥。
