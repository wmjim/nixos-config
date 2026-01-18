# 使用 unstable 版本的包

## 概述

系统已配置 `nixpkgs-unstable` 输入，允许在需要时使用最新版本的包，同时保持系统主体使用稳定版。

## 在系统配置中使用

### 位置
`nixos/configuration.nix`

### 基本用法

```nix
# 在 configuration.nix 中
{ config, lib, pkgs, nixpkgs-unstable, ... }:

let
  # 导入 unstable 包集合（已配置）
  pkgs-unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  environment.systemPackages = with pkgs; [
    # 使用稳定版包（默认）
    vim
    git

    # 使用 unstable 版包（需要最新版本时）
    pkgs-unstable.helix
    pkgs-unstable.some-new-package
  ];
}
```

## 实际应用场景

### 1. 开发工具需要最新版本

```nix
environment.systemPackages = with pkgs; [
  # 稳定版
  python313

  # unstable 版（例如需要最新的 Rust）
  pkgs-unstable.rustc
  pkgs-unstable.cargo
];
```

### 2. 软件包在稳定版中不可用

```nix
environment.systemPackages = with pkgs; [
  # 新发布的软件可能只在 unstable 中
  pkgs-unstable.some-newly-released-app
];
```

### 3. 修复 bug 的版本

```nix
environment.systemPackages = with pkgs; [
  # 稳定版有 bug，使用 unstable 的修复版本
  pkgs-unstable.problematic-package
];
```

## 在 Home Manager 中使用

### 方法一：通过 flake inputs

```nix
# home/cli-common/devel.nix
{ config, pkgs, ... }:

let
  # 访问 unstable（需要通过 specialArgs 传递）
  pkgs-unstable = import <nixpkgs-unstable> {
    config.allowUnfree = true;
  };
in {
  home.packages = with pkgs; [
    pkgs-unstable.neovim
    pkgs-unstable.ripgrep
  ];
}
```

### 方法二：临时使用

```bash
# 临时运行 unstable 包
nix run nixpkgs-unstable#hello

# 临时进入 unstable 环境
nix shell nixpkgs-unstable#ripgrep nixpkgs-unstable#fd

# 从 unstable 安装到系统
nix-env -iA nixpkgs-unstable.package-name
```

## 注意事项

### ⚠️ 谨慎使用

1. **系统稳定性** - unstable 包可能有未知的 bug
2. **依赖冲突** - stable 和 unstable 包混合使用可能导致问题
3. **构建时间** - unstable 包可能没有预编译二进制，需要从源码构建

### 🎯 最佳实践

1. **优先使用稳定版** - 只有在必要时才使用 unstable
2. **明确标记** - 在注释中说明为什么使用 unstable
3. **定期更新** - unstable 更新频繁，定期检查是否可以回到 stable

```nix
environment.systemPackages = with pkgs; [
  # 使用 unstable 原因：稳定版版本过旧，缺少必要功能
  pkgs-unstable.some-package  # v2.0.0 (stable: v1.5.0)
];
```

4. **隔离使用** - 将 unstable 包限制在用户空间，而非系统级

## 更新 unstable

```bash
# 更新所有 inputs（包括 unstable）
nix flake update

# 只更新 unstable
nix flake lock update-input nixpkgs-unstable

# 更新到特定日期的版本
nix flake lock update-input nixpkgs-unstable --commit-hash <hash>
```

## 查看包版本

```bash
# 查看 stable 版本
nix search nixpkgs package-name

# 查看 unstable 版本
nix search nixpkgs-unstable package-name

# 查看已安装的包版本
nix-store -q --references /run/current-system | grep package-name
```

## 故障排查

### unstable 包构建失败

```bash
# 查看构建日志
nix log nixpkgs-unstable#failed-package

# 尝试使用 fallback
nix-build --option fallback true
```

### 依赖冲突

如果遇到 stable 和 unstable 包的依赖冲突：

```nix
# 使用完全独立的 unstable 环境
environment.systemPackages = with pkgs-unstable; [
  # 这些包完全使用 unstable 的依赖链
  package1
  package2
];
```

## 示例配置

### 完整示例

```nix
# nixos/configuration.nix
{ config, lib, pkgs, nixpkgs-unstable, ... }:

let
  pkgs-unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  # 系统包（主要使用 stable）
  environment.systemPackages = with pkgs; [
    # 基础工具（stable）
    wget
    curl
    git
    vim

    # 开发工具（unstable，需要最新特性）
    pkgs-unstable.helix       # 文本编辑器
    pkgs-unstable.eza         # ls 替代品
  ];

  # 用户包（完全使用 unstable）
  users.users.mengw.packages = with pkgs-unstable; [
    ripgrep
    fd
    bat
  ];
}
```

## 相关资源

- [NixOS Manual - Package Management](https://nixos.org/manual/nixos/stable/#sec-package-management)
- [Nixpkgs Unstable Channel](https://github.com/NixOS/nixpkgs/tree/nixos-unstable)
- [NixOS Search](https://search.nixos.org/packages)
