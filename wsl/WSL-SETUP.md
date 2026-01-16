# Arch Linux on WSL 快速安装指南

本指南帮助您在 WSL2 上安装 Arch Linux 并配置 Nix Home Manager。

## 安装 Arch Linux on WSL

### 1. 安装 ArchWSL

```powershell
# 下载最新的 Arch.zip
# https://github.com/yuk7/ArchWSL/releases

# 解压到 C:\WSL\Arch
# 双击 Arch.exe 完成安装
```

### 2. 初始化系统

```bash
# 初始化密钥环
sudo pacman-key --init
sudo pacman-key --populate

# 更新系统
sudo pacman -Syu

# 安装基础工具
sudo pacman -S base-devel git curl sudo
```

### 3. 安装 Nix

```bash
curl -L https://nixos.org/nix/install | sh
source ~/.nix-profile/etc/profile.d/nix.sh
```

配置 Nix：

```bash
mkdir -p ~/.config/nix
cat > ~/.config/nix/nix.conf << 'EOF'
experimental-features = nix-command flakes
EOF
```

### 4. 克隆配置并应用

```bash
# 克隆配置
git clone <your-repo-url> ~/nixos-config
cd ~/nixos-config

# 应用配置（精简版 - 推荐 WSL 使用）
home-manager switch --flake .#mengw@wsl
```

## WSL 优化

### 配置 `/etc/wsl.conf`

```bash
sudo nvim /etc/wsl.conf
```

```ini
[boot]
systemd = true

[automount]
enabled = true
options = "metadata,umask=22,fmask=11"

[interop]
enabled = false
appendWindowsPath = false

[user]
default = mengw
```

### 配置 Git

```bash
git config --global user.name "meng.wang"
git config --global user.email "meng.w1016@outlook.com"
git config --global core.editor "hx"
```

## 常用命令

```bash
# 更新配置
cd ~/nixos-config
home-manager switch --flake .#mengw@linux

# 更新 flake
nix flake update

# 清理旧配置
nix-collect-garbage -d
```

