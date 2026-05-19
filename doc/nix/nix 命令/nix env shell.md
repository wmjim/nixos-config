## 命令

`nix env shell` - 创建并运行一个包含指定软件包的shell。

## 示例 

```bash
# 1. 启动一个 shell，提供来自 nixpkgs flake 的 cowsay 软件包
$ nix shell nixpkgs#cowsay
```