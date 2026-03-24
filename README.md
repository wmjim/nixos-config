## 推荐结构

```bash
~/nix-config/
├── flake.nix
├── hosts/
│   ├── laptop/
│   │   ├── configuration.nix
│   │   └── hardware.nix
│   ├── server/
│   │   └── configuration.nix
│   └── mac/
│       └── darwin.nix
│
├── modules/               # 系统层
│   ├── common/
│   │   ├── cli.nix        # 通用 CLI
│   │   └── dev.nix        # 开发环境
│   │
│   ├── nixos/
│   │   ├── desktop.nix    # GUI（niri）
│   │   └── server.nix
│   │
│   └── darwin/
│       └── default.nix
│
└── home/                  # 用户层
    ├── default.nix        # home-manager（跨平台）
    ├── programs/          # 应用配置
        ├── nvim.nix
        ├── git.nix
        └── shell.nix
    ├── langs/             # 语言环境
    └── services/          # 用户级服务
    
```


## 通用开发环境

CLI 使用 `home-manager` 管理，如：

- git
- neovim
- gcc
- python
- bat

这样无论是 linux 桌面/服务器，或 macOS 都可以使用。

## 系统层

GUI 只属于 nixos，如niri、wayland、fonts，应该放在 `modules/nixos/desktop.nix`


## 设备层

笔记本需要管理：

- niri
- 蓝牙
- 电源管理

服务器：

- ssh
- docker
- 无 GUI
