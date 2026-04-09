## 推荐结构

```bash
nixos-config/
├── flake.nix                    # 统一入口
├── flake.lock
├── README.md                    # 使用文档
│
├── lib/                         # 辅助函数库
│   └── default.nix              # 通用函数（forAllSystems, mkHost等）
│
├── hosts/                       # 主机配置
│   ├── _common/                 # 所有主机共享
│   │   ├── nixos/               # NixOS 通用配置
│   │   │   ├── base.nix         # 基础系统设置
│   │   │   ├── users.nix        # 用户定义
│   │   │   └── locale.nix       # 时区/语言/字体
│   │   └── darwin/              # macOS 通用配置
│   │       ├── base.nix         # 基础系统设置
│   │       ├── users.nix        # 用户定义
│   │       └── homebrew.nix     # Homebrew 配置
│   │
│   ├── laptop/                  # NixOS 笔记本（你的当前配置）
│   │   ├── default.nix
│   │   ├── hardware.nix
│   │   └── desktop.nix          # GNOME 桌面
│   │
│   ├── server/                  # NixOS 无桌面服务器
│   │   ├── default.nix
│   │   ├── hardware.nix
│   │   └── services.nix         # 服务器特定服务
│   │
│   └── macbook/                 # macOS 笔记本
│       ├── default.nix
│       └── homebrew.nix         # mac 专用软件
│
├── modules/                     # 可复用模块
│   ├── nixos/                   # NixOS 专用模块
│   │   ├── desktop/             # 桌面环境
│   │   ├── dev/                 # 开发工具
│   │   ├── network/             # 网络/代理
│   │   └── server/              # 服务器服务
│   │
│   ├── darwin/                  # macOS 专用模块
│   │   ├── defaults.nix         # 系统默认设置
│   │   ├── dock.nix             # Dock 配置
│   │   └── keyboard.nix         # 键盘设置
│   │
│   └── home/                    # Home Manager 模块（跨平台）
│       ├── shell/               # fish, starship, 终端工具
│       ├── editors/             # neovim, helix
│       ├── dev/                 # 语言环境
│       │   ├── go.nix
│       │   ├── rust.nix
│       │   ├── node.nix
│       │   └── python.nix
│       └── apps/                # 跨平台应用
│
├── overlays/                    # 包覆盖
├── pkgs/                        # 自定义包
└── secrets/                     # 加密 secrets（sops-nix）
    └── default.nix
```


```bash
# 构建 NixOS 笔记本
sudo nixos-rebuild switch --flake .#laptop

# 构建 NixOS 服务器
sudo nixos-rebuild switch --flake .#server

# 构建 macOS（在 Mac 上）
darwin-rebuild switch --flake .#macbook
```
