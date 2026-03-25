



## 查看与清理历史数据

NixOS 每次部署都会生成一个新的版本，所有版本都会被添加到系统启动项中。

```bash
# 1. 查询当前可用所有历史版本
nix profile history --profile /nix/var/nix/profiles/system

# 2. 清理 7 天之前的所有历史版本
sudo nix profile wipe-history --older-than 7d --profile /nix/var/nix/profiles/system

# 3. 删除所有未使用的包
sudo nix-collect-garbage --delete-old
```
