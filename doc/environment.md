# 开发环境

## 全局环境

**全局环境**：由 home-manager 管理的用户环境（`modules/home-manager/cli/dev`）。

- Shell：Fish + 常用 CLI 工具（eza / zoxide / bat / fzf / ripgrep / fd / jq / yq）
- 编辑器：Helix（`hx`）+ VSCode（GUI）+ JetBrains 全家桶 + Zed
- AI 编程：Claude Code（`cc` 别名）、pi-coding-agent

### 语言工具链

| 语言 | 工具 | LSP / 辅助 |
| --- | --- | --- |
| Go | `go` | gopls |
| Node.js | `nodejs_latest`、`yarn`、`pnpm` | typescript-language-server、prettier、eslint |
| Rust | `rustc`、`cargo` | rust-analyzer、rustfmt、clippy、cargo-watch/audit/outdated/nextest、taplo、cargo-cross |
| Python | `python315`、`uv` | python-lsp-server、ruff、black、isort、mypy、pytest、pylint、bandit、mkdocs |
| C/C++ | `clang`、`cmake`、`ninja`、`vcpkg`、`xmake` | clangd（clang-tools）、cppcheck、lldb、valgrind、perf-tools、strace |
| 其他 | bash / lua / nix / markdown / yaml / kdl | bash-language-server、lua-language-server、nil、marksman、ltex-ls-plus、yaml-language-server、kdlfmt |

> 注意：Python 使用 `uv` 作为首选包管理器（替代 pip/poetry）。

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

- `nix shell`：用于进入到一个含有指定 Nix 包的环境并为它打开一个交互式 shell。
- `nix run`：用于直接运行一个 Nix 包，而不需要进入环境。

## 容器的开发环境（Distrobox）

desktop / laptop 已启用 Distrobox + Podman，可快速进入其它发行版环境：

```bash
arch     # distrobox enter arch
ubuntu   # distrobox enter ubuntu
```
