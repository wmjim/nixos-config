- [Nix 官方文档](https://nix.dev/manual/nix)：查询 Nix 语法的完整用法
- [Nix 函数库搜索器](https://noogle.dev/)：快速查找函数用法
- [Nix 官方入门教程](https://nix.dev/tutorials/nix-language)

- [Nix 语言中文教程](https://nixos-cn.org/tutorials/lang/)：用户编写，非官方

## 安装 Nix

```bash
# linux or wsl2
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon

# macos
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
```

> [!NOTE]
>
> - **在 Linux 上**：当它检测到是 Linux 系统时，`--daemon` 标志会触发完整的 `nix-daemon` 守护进程、构建沙箱和 `/nix` 存储权限设置等配置。可以说， **`--daemon`** **标志是为了在 Linux 上“激活”最完整的多用户特性**。
> - **在 macOS 上**：当它检测到是 macOS 系统时，会自动启用多用户模式，但不会像在 Linux 上那样“激活”所有功能。这和 Linux 上不加 `--daemon` 的单用户模式是不同的。
