# NixOS 配置优化总结

本文档总结了已完成的所有优化改进。

## ✅ 已完成的优化

### 1. 性能优化

#### 多核并行构建
**文件**: [nixos/configuration.nix](../nixos/configuration.nix#L27-L35)

```nix
nix.settings = {
  max-jobs = 8;   # 并行构建任务数
  cores = 8;      # CPU 核心数
  sandbox = true; # 构建沙箱
}
```

#### 二进制缓存
**文件**: [nixos/configuration.nix](../nixos/configuration.nix#L40-L51)

```nix
substituters = [
  "https://nix-community.cachix.org"
  "https://cache.nixos.org"
];
```

#### 内核参数调优
**文件**: [nixos/configuration.nix](../nixos/configuration.nix#L110-L140)

- BBR 拥塞控制算法
- 网络缓冲区优化
- 文件系统优化
- 内存管理优化
- 安全性增强

### 2. 包管理增强

#### nixpkgs-unstable 支持
**文件**: [flake.nix](../flake.nix#L8-L9), [nixos/configuration.nix](../nixos/configuration.nix#L5-L12)

可以在需要时使用最新版本的包：

```nix
let
  pkgs-unstable = import nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in {
  environment.systemPackages = with pkgs; [
    pkgs-unstable.helix  # 使用最新版本
  ];
}
```

**文档**: [docs/unstable-packages.md](unstable-packages.md)

#### nix-index 快速查找
**文件**: [nixos/configuration.nix](../nixos/configuration.nix#L222-L226), [nixos/nix-index.nix](../nixos/nix-index.nix)

```bash
# 查找命令对应的包
nix-locate fd

# 自动每周更新索引
```

**文档**: [docs/nix-index.md](nix-index.md)

### 3. 配置结构优化

#### 环境变量统一管理
**文件**: [nixos/env.nix](../nixos/env.nix), [home/env.nix](../home/env.nix)

- 系统级环境变量集中在 `nixos/env.nix`
- 用户级环境变量集中在 `home/env.nix`
- 消除了 Fish、Wayland 等配置中的重复

**文档**: [docs/env-vars.md](env-vars.md)

#### 字体配置优化
**文件**: [nixos/configuration.nix](../nixos/configuration.nix#L97-L121)

- 移除了 `home/gui/fonts.nix` 中的重复配置
- 添加了完整的中文字体支持（思源黑体、思源宋体）
- 添加了 Emoji 支持

### 4. 新增文档

#### 完整的使用指南
- [docs/unstable-packages.md](unstable-packages.md) - unstable 包使用指南
- [docs/nix-index.md](nix-index.md) - nix-index 详细使用说明
- [docs/nix-tools-quickref.md](nix-tools-quickref.md) - Nix 工具快速参考
- [docs/env-vars.md](env-vars.md) - 环境变量管理说明
- [docs/structure.md](structure.md) - 配置结构说明

## 📊 优化效果

### 性能提升
- ✅ **构建速度**: 8 核并行构建，显著提升编译速度
- ✅ **下载速度**: 二进制缓存加速包下载
- ✅ **网络性能**: BBR + TCP Fast Open 提升网络吞吐
- ✅ **系统响应**: swappiness=10 减少交换，提升响应速度

### 可维护性提升
- ✅ **配置清晰**: 环境变量统一管理，不再分散
- ✅ **易于查找**: nix-index 快速定位包
- ✅ **灵活性强**: 可选择性使用 unstable 包
- ✅ **文档完善**: 详细的使用指南和示例

### 安全性增强
- ✅ **反向路径过滤**: 防止 IP 欺骗
- ✅ **禁止源路由**: 防止路由攻击
- ✅ **构建沙箱**: 隔离构建环境
- ✅ **自动垃圾回收**: 定期清理旧数据

## 🚀 快速开始

### 应用所有优化

```bash
# 更新 flake inputs（添加 nixpkgs-unstable）
nix flake update

# 重建系统
nix-rebuild
```

### 生成 nix-index 索引

```bash
# 首次使用需要生成索引（约 5 分钟）
nix-index
```

### 使用 unstable 包

```bash
# 临时使用 unstable 包
nix run nixpkgs-unstable#hello

# 查找命令对应的包
nix-locate fd
```

## 📝 配置概览

### 目录结构

```
nixos-config/
├── flake.nix                    # Flake 入口（添加了 nixpkgs-unstable）
├── nixos/
│   ├── configuration.nix        # 系统配置（性能优化 + 内核调优）
│   ├── env.nix                  # 系统级环境变量
│   └── nix-index.nix            # nix-index 自动更新
├── home/
│   ├── env.nix                  # 用户级环境变量
│   └── ...
└── docs/
    ├── unstable-packages.md     # unstable 包指南
    ├── nix-index.md             # nix-index 使用说明
    ├── nix-tools-quickref.md    # 快速参考
    └── env-vars.md              # 环境变量管理
```

### 核心配置

1. **Nix 构建优化** ([configuration.nix:24-51](../nixos/configuration.nix#L24-L51))
   - 多核并行构建
   - 二进制缓存
   - 自动垃圾回收

2. **内核参数调优** ([configuration.nix:110-140](../nixos/configuration.nix#L110-L140))
   - 网络性能优化
   - 文件系统优化
   - 内存管理优化
   - 安全性增强

3. **包管理工具** ([configuration.nix:222-226](../nixos/configuration.nix#L222-L226))
   - nix-index: 快速查找包
   - nix-tree: 依赖可视化
   - nix-output-monitor: 构建监控

4. **unstable 支持** ([flake.nix:8-9](../flake.nix#L8-L9), [configuration.nix:5-12](../nixos/configuration.nix#L5-L12))
   - 可选择性使用最新版本
   - 保持系统主体稳定

## 🎯 最佳实践

1. **优先使用 stable** - 只有在必要时才使用 unstable
2. **定期更新索引** - nix-index 每周自动更新
3. **监控资源使用** - 使用 `nix-tree` 查看依赖
4. **查看构建日志** - 使用 `nom` 美化输出

## 🔍 故障排查

### nix-index 找不到包

```bash
# 更新索引
nix-index

# 或更新 nixpkgs
nix flake update
```

### unstable 包构建失败

```bash
# 查看构建日志
nix log nixpkgs-unstable#failed-package

# 尝试使用稳定版
```

### 性能问题

```bash
# 检查 CPU 使用
htop

# 查看内核参数
sysctl net.ipv4.tcp_congestion_control
sysctl vm.swappiness
```

## 📚 相关资源

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [NixPkgs Reference](https://nixos.org/manual/nixpkgs/stable/)
- [NixOS Search](https://search.nixos.org/)
- [nix-index GitHub](https://github.com/nix-community/nix-index)
- [deploy-rs GitHub](https://github.com/serokell/deploy-rs)

## 🎉 总结

通过这些优化，你的 NixOS 配置现在具有：

- ⚡ **更好的性能** - 多核构建、内核调优、二进制缓存
- 🔍 **更强的可发现性** - nix-index 快速查找包
- 🎯 **更灵活的包管理** - stable + unstable 双通道
- 🗂️ **更清晰的结构** - 统一的环境变量管理
- 📚 **更完善的文档** - 详细的使用指南

享受优化后的 NixOS 体验！
