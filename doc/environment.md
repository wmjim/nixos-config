# 开发环境


## 全局环境

**全局环境**：由 home-manager 管理的用户环境。

- 通用的开发工具：`git`、`hx` 等
- 各语言 SDK 和包管理器：`c/c++`、`python`、`rust` 等

## 项目环境

**项目环境**：每个项目通过 `flake.nix` 定义开发定制环境。

项目环境的优先级是最高的，其中的依赖会覆盖全局环境中的同名依赖。

### nix shell

```bash
$ hello
fish: 未知的命令：hello

# 1. 进入一个包含 hello 的临时环境
$ nix shell nixpkgs#hello
$ hello
世界你好！

# 2. 退出环境
$ exit

# 3. 直接运行 cowsay，用完即走
nix run nixpkgs#cowsay -- "Hello, Nix!"
```

- `nix shell`：用于进入到一个含有指定 Nix 包的环境并为它打开一个交互式 shell 。
- `nix run`：用于直接运行一个 Nix 包，而不需要进入环境。


**开发环境模板**

- [nix-templates](https://github.com/MordragT/nix-templates)
- [dev-templates](https://github.com/the-nix-way/dev-templates)

