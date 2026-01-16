# NixOS 配置

这是我的 NixOS 和跨平台 dotfiles 配置，使用 Nix Flakes 和 Home Manager 管理。

## 项目结构

```
.
├── flake.nix              # Flakes 入口文件
├── nixos/                 # NixOS 系统配置
│   ├── configuration.nix  # 主配置文件
│   └── hardware-configuration.nix  # 硬件配置
├── home/                  # Home Manager 配置
│   ├── cli-common/        # 跨平台 CLI 工具（Arch/NixOS/macOS）
│   ├── nixos-cli/         # NixOS 专用 CLI 工具
│   ├── gui/               # NixOS GUI 应用
│   ├── wsl/               # WSL/Arch Linux 专用配置
│   └── linux/             # Linux 通用配置
├── darwin/                # macOS 配置（待实现）
├── linux/                 # Linux 特定配置
├── HOME-STRUCTURE.md      # Home 目录结构说明
└── WSL-SETUP.md           # WSL 安装指南
```

## 配置说明

### Home 目录结构

本项目采用模块化设计，按使用场景和平台分类：

- **cli-common/** - 跨平台通用 CLI 工具（Fish, Helix, Zellij, Git, 开发工具）
- **nixos-cli/** - NixOS 专用 CLI 工具（Kitty 终端）
- **gui/** - NixOS GUI 应用（Hyprland, Waybar, Wofi）
- **wsl/** - WSL/Arch Linux 专用配置

详细说明请查看 [HOME-STRUCTURE.md](HOME-STRUCTURE.md)

## 使用方式

```bash
# NixOS（完整配置：CLI + GUI）
sudo nixos-rebuild switch --flake .#nixos

# WSL/Arch Linux（CLI only）
home-manager switch --flake .#mengw@linux

# WSL/Arch Linux（精简配置）
home-manager switch --flake .#mengw@wsl
```

## 常用命令

### 系统管理

```bash
# 重建并切换到新配置
sudo nixos-rebuild switch --flake .#nixos

# 测试配置而不切换
sudo nixos-rebuild test --flake .#nixos

# 更新 flake 输入
nix flake update
```

### 开发工作流

```bash
# 检查配置语法
nix flake check

# 显示将要重建的内容
nixos-rebuild dry-build --flake .#nixos
```

### WSL 管理

```bash
# 更新 WSL 配置
cd ~/nixos-config
home-manager switch --flake .#mengw@linux

# 清理旧配置
nix-collect-garbage -d
```

## 主要功能

### 终端环境
- **Fish Shell** - 智能补全和语法高亮
- **Zoxide** - 智能目录跳转
- **Fzf** - 模糊搜索
- **Eza** - 现代 ls 替代品

### 开发工具
- **Helix** - 模态编辑器，内置 LSP
- **Zellij** - 现代终端复用器
- **C++ 工具链** - Clang, CMake, Ninja
- **LSP 服务器** - Nix, Rust, Python, TypeScript

### NixOS GUI
- **Hyprland** - Wayland 合成器
- **Waybar** - 状态栏
- **Wofi** - 应用启动器
- **Kitty** - GPU 加速终端

## 安装指南

- **NixOS**: 直接应用配置即可
- **WSL/Arch**: 请查看 [WSL-SETUP.md](WSL-SETUP.md)

## 最近更新

- ✅ 重构 home 目录结构，按平台分类
- ✅ 添加 WSL 专用配置
- ✅ 优化 devel.nix 和 fish.nix
- ✅ 添加详细文档

## 参考资源

- [NixOS 手册](https://nixos.org/manual/nixos/stable/)
- [Home Manager 手册](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
