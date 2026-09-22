# 架构速查

面向 Agent 与人的仓库地图：仓库结构、选项映射、module 分层、主机清单。
改配置前先看这里，能省一轮反推。

## 仓库结构

在进行更改之前，检查仓库结构并识别相关的主机/模块：

```text
flake.nix / flake.lock      # 唯一入口：inputs + 5 个主机输出 + devShell/formatter
├─ lib/                     # 1 个函数库（wrapQtXWayland）
├─ hosts/                   # 每台主机 = 声明文件 + nixos-generate-config 产物
│  ├─ _common/darwin/       # macOS 共享 base/users（NixOS 侧无对应物）
│  ├─ desktop/              # hardware.nix + nvidia.nix + 主机专属补丁
│  ├─ laptop/               # hardware.nix + laptop.nix + nvidia.nix
│  ├─ wsl/  server/         # 仅 CLI；server 是 stub
│  └─ macbook/              # nix-darwin 入口
├─ modules/
│  ├─ nixos/{core,desktop,hardware,networking,virtualization}/  # 系统层，core 全量导入
│  ├─ home-manager/{cli,gui}/                                   # 用户层，跨 NixOS + darwin
│  └─ darwin/                                                   # macOS 系统层
├─ pkgs/                    # 自打包（3 个主题 + mcpp-m + windows-vm-media）
├─ docs/                    # 子系统深度说明，索引见 docs/README.md
├─ tests/                   # 本机冒烟脚本（tmux-persistence.sh）
└─ .github/workflows/       # flake-check（eval + dry-build）、flakehub-publish
```

编辑之前：
1. 检查 `flake.nix`
2. 确认目标 `nixosConfiguration`
3. 检查相关主机配置
4. 在添加新配置之前，先搜索现有的模块/选项。

## 基于选项的主机配置 (`mySystem` 命名空间)

无需为每台主机单独导入模块，所有功能模块都由 `core/default.nix` 无条件导入，再通过选项开关控制是否生效。选项**就近定义在各自功能模块中**，只有三个顶层域开关集中在 `core/default.nix`：

```nix
options.mySystem = {
  hardware.enable = ...;
  desktop.enable = ...;
  virtualization.enable = ...;
};
```

各模块通过 `lib.mkIf config.mySystem.<foo>.enable` 实现条件启用。新增功能时，选项应定义在实现该功能的模块文件里（而非集中到 core），再在对应域的聚合模块中用 `lib.mkDefault` 给出默认开关值。

## 选项 → 文件映射

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
| `mySystem.desktop.gnome.extensions` | `modules/nixos/desktop/gnome/default.nix` | 扩展包单一来源，hm 侧 dconf `enabled-extensions` 由各包 `extensionUuid` 派生 |
| `mySystem.desktop.scale` | `modules/nixos/desktop/default.nix` | 分数缩放，AWT 应用会向上取整 |
| `mySystem.desktop.distrobox.enable` | `modules/nixos/desktop/distrobox.nix` | |
| `mySystem.desktop.steam.enable` | `modules/nixos/desktop/steam.nix` | |

## Module layering

```
modules/
  nixos/core/       在所有NixOS主机中永久导入：用户配置、区域语言、硬件适配、桌面环境、虚拟化、网络组件
  nixos/desktop/    永久导入，由mySystem.desktop.enable控制生效：boot、GDM、env、Niri、GNOME、Distrobox、Steam
  nixos/hardware/   永久导入，由mySystem.hardware.enable控制生效：音频（PipeWire）、蓝牙、网络（iwd+NetworkManager）、MCU工具链、NVIDIA基础驱动（后者需显式开启）
  home-manager/     多用户共用配置，同时兼容 NixOS 与 macOS 系统
    cli/            通用加载项：Shell（Fish）、编辑器（Neovim）、开发工具、TUI终端交互工具
    gui/            仅用于桌面用户加载：应用程序（含嵌入式工具链）、备用主题、窗口管理器（Niri / Noctalia）、VSCode、Fcitx5输入法
  darwin/           macOS专属配置：系统默认设置、Homebrew图形化应用包
```

## `mkHomeManager` 样板代码

`flake.nix` 中定义了 `mkHomeManager` 函数，用于生成所有 NixOS 主机共用的 Home-Manager 集成配置块。带图形界面的主机传入参数 `extraModules = [ ./modules/home-manager/gui ]`；无图形服务器主机与 WSL 环境主机则不传入该参数。macOS 系统使用独立的内联 Home-Manager 配置块（不调用 `mkHomeManager`），原因是其需要通过 `lib.mkForce` 强制覆盖 NUR 软件源覆盖层，且共用模块的配置逻辑与 NixOS 不同。

## 各主机配置

| Host | System | Key features |
|------|--------|-------------|
| desktop | x86_64-linux | Niri WM, NVIDIA RTX 3060Ti, 4K@150Hz |
| laptop | x86_64-linux | Niri WM（默认会话；GNOME 也装）, NVIDIA MX150 (legacy driver, PRIME offload), btrfs, TLP |
| wsl | x86_64-linux | CLI-only, WSL container |
| server | x86_64-linux | Stub, only nixosCore |
| macbook | aarch64-darwin | nix-darwin, Homebrew casks |
