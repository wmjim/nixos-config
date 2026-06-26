## 资源

- [查找包](https://search.nixos.org/packages)
- [查找设置](https://search.nixos.org/options)
- [更快的搜索](https://nixsearch.thekoppe.com/)
- [NixOS 中文](https://nixos-cn.org/manual/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/zh/introduction/)
- [NixOS 中文论坛](https://discourse.nixos.org/c/learn/chinese/55)
- [Awesome-Nix](https://github.com/nix-community/awesome-nix)

## 部署新配置

```bash
# NixOS 笔记本
sudo nixos-rebuild switch --flake ~/nixos-config#laptop

# NixOS 主机
sudo nixos-rebuild switch --flake ~/nixos-config#desktop

# WSL
sudo nixos-rebuild switch --flake ~/nixos-config#wsl

# NixOS 服务器（未测试，待补充）
# sudo nixos-rebuild switch --flake ~/nixos-config#server

# MacOS（未测试，待补充）
# darwin-rebuild switch --flake ~/nixos-config#macbook
```

## 常用命令

```bash
# 更新 flake.lock
nix flake update

# 删除所有旧版本的配置文件
nix-collect-garbage --delete-old

# 存储优化
nix store optimise
```

## 我的配置

- 终端Shell：[Fish](https://github.com/fish-shell/fish-shell)
- 终端编辑器：[Helix](https://github.com/helix-editor/helix)

