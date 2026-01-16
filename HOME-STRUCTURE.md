# Home 目录结构说明

本项目采用模块化的配置结构，将配置按使用场景和平台进行分类。

## 目录结构

```
home/
├── cli-common/          # 跨平台通用 CLI 工具（Arch/NixOS/macOS）
│   ├── default.nix      # 入口文件，导入所有 CLI 配置
│   ├── git.nix          # Git 配置
│   ├── shell.nix        # Shell 工具配置（direnv）
│   ├── fish.nix         # Fish Shell 配置
│   ├── helix.nix        # Helix 编辑器配置
│   ├── zellij.nix       # Zellij 终端复用器配置
│   └── devel.nix        # 开发工具配置
│
├── nixos-cli/           # NixOS 专用 CLI 工具
│   ├── default.nix      # 入口文件
│   └── kitty.nix        # Kitty 终端模拟器配置
│
├── gui/                 # NixOS GUI 应用
│   ├── default.nix      # 入口文件
│   ├── wayland.nix      # Hyprland Wayland 合成器配置
│   ├── waybar.nix       # Waybar 状态栏配置
│   ├── wofi.nix         # Wofi 应用启动器配置
│   └── fonts.nix        # 字体配置
│
├── wsl/                 # WSL/Arch Linux 专用配置
│   └── default.nix      # WSL 特定配置（引用 cli-common）
│
└── linux/               # Linux 通用配置（非 NixOS）
    └── default.nix      # Linux 特定配置
```

## 各目录说明

### `cli-common/` - 跨平台通用 CLI 工具

适用于所有平台的命令行工具配置：
- **git.nix** - Git 版本控制配置
- **shell.nix** - Shell 环境工具（direnv）
- **fish.nix** - Fish Shell 及其插件、别名、函数
- **helix.nix** - Helix 编辑器配置
- **zellij.nix** - Zellij 终端复用器配置
- **devel.nix** - 开发工具（C++ 工具链、LSP 服务器、格式化工具等）

**使用场景：**
- ✅ NixOS（物理机/虚拟机）
- ✅ Arch Linux（WSL 或物理机）
- ✅ 其他 Linux 发行版
- ✅ macOS（需要时启用）

### `nixos-cli/` - NixOS 专用 CLI 工具

仅适用于 NixOS 的 CLI 工具：
- **kitty.nix** - Kitty 终端模拟器（依赖 NixOS 的字体配置）

**使用场景：**
- ✅ NixOS（物理机/虚拟机）
- ❌ Arch Linux
- ❌ macOS

### `gui/` - NixOS GUI 应用

NixOS 的图形界面相关配置：
- **wayland.nix** - Hyprland Wayland 合成器及窗口管理
- **waybar.nix** - Waybar 状态栏及系统模块
- **wofi.nix** - Wofi 应用启动器
- **fonts.nix** - 额外字体配置

**使用场景：**
- ✅ NixOS（物理机/虚拟机）使用 Wayland
- ❌ WSL（无图形界面）
- ❌ 纯 CLI 环境

### `wsl/` - WSL/Arch Linux 专用配置

WSL 环境的特定配置：
- 引用 `cli-common` 获取跨平台 CLI 工具
- WSL 环境变量配置
- WSL 专用工具（wslu, wl-clipboard）
- Windows 路径别名

**使用场景：**
- ✅ Arch Linux on WSL
- ✅ 其他发行版 on WSL（需适当调整）

### `linux/` - Linux 通用配置

非 NixOS 的 Linux 发行版通用配置：
- 目前为空，可根据需要添加 Linux 特定配置

## Flake 配置示例

### NixOS 配置（完整）

```nix
home-manager.users.mengw = {
  imports = [
    ./home/cli-common   # 跨平台 CLI 工具
    ./home/nixos-cli    # NixOS 专用 CLI 工具
    ./home/gui          # GUI 应用
  ];
};
```

### WSL/Arch 配置（CLI only）

```nix
homeConfigurations."mengw@linux" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [
    ./home/cli-common   # 跨平台 CLI 工具
    ./home/wsl          # WSL 特定配置
  ];
};
```

### 纯 Arch Linux 配置

```nix
homeConfigurations."mengw@arch" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [
    ./home/cli-common   # 跨平台 CLI 工具
    ./home/linux        # Linux 特定配置
  ];
};
```

### macOS 配置（未来）

```nix
home-manager.users.mengw = {
  imports = [
    ./home/cli-common   # 跨平台 CLI 工具
    ./home/macos        # macOS 特定配置（待创建）
  ];
};
```

## 添加新配置

### 添加跨平台 CLI 工具

在 `home/cli-common/` 目录下创建新的 `.nix` 文件，然后在 `default.nix` 中导入：

```nix
# home/cli-common/default.nix
{ config, pkgs, ... }:

{
  imports = [
    ./git.nix
    ./shell.nix
    ./fish.nix
    ./helix.nix
    ./zellij.nix
    ./devel.nix
    ./your-new-tool.nix  # 添加新工具
  ];
}
```

### 添加 NixOS 专用工具

在 `home/nixos-cli/` 或 `home/gui/` 目录下创建新文件。

### 添加 WSL 特定配置

直接在 `home/wsl/default.nix` 中添加。

## 设计原则

1. **模块化** - 每个文件专注于单一功能
2. **可复用** - 跨平台配置放在 `cli-common`
3. **清晰分层** - 按平台和用途分离配置
4. **易于维护** - 新增配置时明确知道应该放在哪个目录

## 迁移说明

如果您有旧的配置文件，按照以下规则迁移：

- **所有平台的 CLI 工具** → `cli-common/`
- **仅 NixOS 的 CLI 工具** → `nixos-cli/`
- **NixOS GUI 应用** → `gui/`
- **WSL 特定配置** → `wsl/`
- **通用 Linux 配置** → `linux/`
- **macOS 配置** → 创建 `macos/` 目录
