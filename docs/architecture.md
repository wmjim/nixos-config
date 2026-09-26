# 架构速查

面向 Agent 与人的仓库地图：仓库结构、选项映射、module 分层、主机清单。
改配置前先看这里，能省一轮反推。

## 仓库结构

在进行更改之前，检查仓库结构并识别相关的主机/模块：

```text
flake.nix / flake.lock      # 唯一入口：inputs + 5 个主机输出 + overlays/packages/checks + devShell/formatter
├─ lib/                     # 1 个函数库（wrapQtXWayland）
├─ hosts/                   # 每台主机 = 声明文件 + nixos-generate-config 产物
│  ├─ desktop/              # hardware.nix + nvidia.nix + 主机专属补丁
│  ├─ laptop/               # hardware.nix + laptop.nix + nvidia.nix
│  ├─ wsl/  server/         # 仅 CLI；server 是 stub
│  └─ macbook/              # nix-darwin 入口（共享层在 modules/darwin）
├─ modules/
│  ├─ nixos/{core,desktop,hardware,networking,virtualization}/  # 系统层，core 全量导入
│  ├─ home-manager/{cli,gui}/                                   # 用户层，跨 NixOS + darwin
│  └─ darwin/               # macOS 系统层（base/users/gui，含共享层）
├─ overlays/                # 自定义包 overlay（pkgs/ 的单一注入点，flake 暴露 overlays/packages）
├─ pkgs/                    # 自打包（3 个主题 + mcpp-m + windows-vm-media）
├─ docs/                    # 子系统深度说明，索引见 docs/README.md
├─ tests/                   # 本机冒烟脚本（tmux-persistence.sh）
└─ .github/workflows/       # flake-check（eval + dry-build + niri validate）、flakehub-publish
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
| `mySystem.primaryUser` | `modules/nixos/core/users.nix` | 主用户名：configDir、trusted-users、HM 集成、keyd 组授权均由此派生，改用户名只动这一处 |
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
| `mySystem.desktop.monitors` | `modules/nixos/desktop/default.nix` | 显示器声明（主机数据）：驱动 niri `outputs.kdl` 生成与 Noctalia DDC 亮度，`ddc = true` 的输出走 DDC/CI |
| `mySystem.desktop.scale` | `modules/nixos/desktop/default.nix` | 逻辑缩放，默认从 `monitors` 首项派生；AWT 应用会向上取整 |
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
  darwin/           macOS专属配置：base（nix 设置、系统级包）、users、GUI（系统默认值、Homebrew casks）
```

## Overlay 与自定义包

`overlays/default.nix` 是 `pkgs/` 自维护包的单一注入点，三处消费同一份清单：

- NixOS 系统级：`modules/nixos/core` 的 `nixpkgs.overlays`
- macOS 系统级：`modules/darwin/base` 的 `nixpkgs.overlays`
- flake 输出：`overlays.default` 与 `packages.*`（`nix flake check` 会逐一评估，
  nixpkgs 滚动带来的包级回归在 CI 即暴露）

Home Manager 走 `useGlobalPkgs = true` 复用系统级实例，不单独注入 overlay。

## `mkHomeManager` 样板代码

`flake.nix` 中定义了 `mkHomeManager` 函数，用于生成所有 NixOS 主机共用的 Home-Manager 集成配置块。带图形界面的主机传入参数 `extraModules = [ ./modules/home-manager/gui ]`；无图形服务器主机与 WSL 环境主机则不传入该参数。集成的用户名由 `mySystem.primaryUser` 派生（不硬编码）。macOS 系统使用独立的内联 Home-Manager 配置块（不调用 `mkHomeManager`），同样 `useGlobalPkgs = true`，overlay 由 `modules/darwin/base` 在系统级注入。

## 各主机配置

| Host | System | Key features |
|------|--------|-------------|
| desktop | x86_64-linux | Niri WM, NVIDIA RTX 3060Ti, 4K@150Hz |
| laptop | x86_64-linux | Niri WM（默认会话；GNOME 也装）, NVIDIA MX150 (legacy driver, PRIME offload), btrfs, TLP |
| wsl | x86_64-linux | CLI-only, WSL container |
| server | x86_64-linux | Stub, only nixosCore |
| macbook | aarch64-darwin | nix-darwin, Homebrew casks |
