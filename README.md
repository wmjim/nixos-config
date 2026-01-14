
## 使用方式

```bash
# NixOS
sudo nixos-rebuild switch --flake /home/mengw/nixos-config#nixos

# macOS
darwin-rebuild switch --flake .#macbook

# Arch/WSL
home-manager switch --flake .#mengw@arch-wsl
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

