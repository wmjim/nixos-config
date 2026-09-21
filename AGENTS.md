# AGENTS.md

该文件用于为 Agent 提供指引，方便其处理本代码仓库内的代码。

## 命令

```bash
# Agent 可以自行执行（只读，或只写仓库内文件）
nix fmt                                  # 格式化所有 Nix 文件（nixpkgs-fmt）
nix develop                              # 开发环境 (git + nixpkgs-fmt)
# 求值与 dry-run 构建见下节「验证」
```

```bash
# 只由用户本人执行，Agent 不要运行
sudo nixos-rebuild switch --flake ~/Projects/nixos-config#desktop
sudo nixos-rebuild switch --flake ~/Projects/nixos-config#laptop
sudo nixos-rebuild switch --flake ~/Projects/nixos-config#wsl
# 详细构建日志 (用于排错调试)
sudo nixos-rebuild switch --flake ~/Projects/nixos-config#desktop --show-trace --print-build-logs --verbose
nix flake update [<input>]               # 改写 flake.lock
sudo nix-collect-garbage --delete-old    # 删旧代际
```

Agent 不执行 `nixos-rebuild switch` / `darwin-rebuild switch` / `nix-collect-garbage`，也不执行任何 `sudo`：前者切换系统代际（会踢掉正在跑的会话），后者删旧代际，都不可逆。`nix flake update` 只在用户明确要求时跑。Agent 的职责边界是**改完保证能求值**，切换与清理交给用户本人。

## 验证

改完配置的默认验收标准：`nix fmt` + 对**受影响的主机**跑 dry-run 求值（与 CI 同款检查，本机约 10 秒）。

```bash
# 单点查值（约 0.5 秒）：确认某选项的最终值、是否被 mkIf/mkForce 影响，比翻文件快
nix eval --raw '.#nixosConfigurations.desktop.config.<选项路径>'

# 全量求值（约 10 秒）：算出整机 toplevel 闭包，只求值、不构建
nix build --dry-run --no-write-lock-file '.#nixosConfigurations.desktop.config.system.build.toplevel'

# CI 第一个 job 的同款检查
nix flake check --no-write-lock-file
```

- 跑哪些主机由**改动的影响范围**决定：改 `hosts/<host>/` 或单个功能模块 → 只跑该 host；改 `modules/nixos/core/`、`flake.nix`、`lib/`、`overlays/` → 「各主机配置」表里 5 个目标全跑（含 `darwinConfigurations.macbook`）。
- 改了 tmux 模块 → 提示用户在 `switch` 后跑 `./tests/tmux-persistence.sh`（它读的是已生成的配置，自建沙箱、不碰运行中的 tmux server）。
- GUI 渲染、硬件行为、Windows 客户机这类本机无法验证的部分，必须写明「未验证」，不要声称已验证。
- 核对桌面（niri）配置要连**生成的文件**一起看：有效配置 = `modules/home-manager/gui/wm/config/`（symlink 到 `~/.config/niri`）+ `wm/default.nix` 生成的 `~/.config/niri-colors/{layout,overview}.kdl` 与 `~/.config/niri-outputs/outputs.kdl`。`Mod+Tab` 系列绑定就生成在 `overviewKdl` 里，只 grep `config/` 会得出错误结论。

## 架构

### 基于选项的主机配置 (`mySystem` 命名空间)

无需为每台主机单独导入模块，所有功能模块都由 `core/default.nix` 无条件导入，再通过选项开关控制是否生效。选项**就近定义在各自功能模块中**，只有三个顶层域开关集中在 `core/default.nix`：

```nix
options.mySystem = {
  hardware.enable = ...;
  desktop.enable = ...;
  virtualization.enable = ...;
};
```

各模块通过 `lib.mkIf config.mySystem.<foo>.enable` 实现条件启用。新增功能时，选项应定义在实现该功能的模块文件里（而非集中到 core），再在对应域的聚合模块中用 `lib.mkDefault` 给出默认开关值。

### 选项 → 文件映射

| 选项 | 定义位置 | 说明 |
|------|----------|------|
| `mySystem.hardware.enable` | `modules/nixos/core/default.nix` | 顶层域开关，开启后默认连带启用下列 hardware 子选项 |
| `mySystem.desktop.enable` | `modules/nixos/core/default.nix` | 顶层域开关 |
| `mySystem.virtualization.enable` | `modules/nixos/core/default.nix` | 顶层域开关（QEMU/KVM） |
| `mySystem.users.<name>.{enable,extraGroups,shell}` | `modules/nixos/core/users.nix` | 用户声明，主机配置中覆盖 |
| `mySystem.proxy.{enable,port,extraNoProxy}` | `modules/nixos/networking/proxy.nix` | 本机 HTTP 代理（Clash Verge） |
| `mySystem.hardware.audio.enable` | `modules/nixos/hardware/audio.nix` | PipeWire |
| `mySystem.hardware.bluetooth.enable` | `modules/nixos/hardware/bluetooth.nix` | |
| `mySystem.hardware.network.enable` | `modules/nixos/hardware/network.nix` | iwd + NetworkManager |
| `mySystem.hardware.mcu.enable` | `modules/nixos/hardware/mcu.nix` | 嵌入式开发工具链 |
| `mySystem.hardware.nvidia.enable` | `modules/nixos/hardware/nvidia-base.nix` | 需主机显式开启（server/WSL 不需要） |
| `mySystem.desktop.niri.enable` | `modules/nixos/desktop/default.nix` | Niri WM |
| `mySystem.desktop.gnome.enable` | `modules/nixos/desktop/default.nix` | GNOME |
| `mySystem.desktop.gnome.extensions` | `modules/nixos/desktop/gnome/default.nix` | 扩展包单一来源，hm 侧 dconf `enabled-extensions` 由各包 `extensionUuid` 派生 |
| `mySystem.desktop.scale` | `modules/nixos/desktop/default.nix` | 分数缩放，AWT 应用会向上取整 |
| `mySystem.desktop.distrobox.enable` | `modules/nixos/desktop/distrobox.nix` | |
| `mySystem.desktop.steam.enable` | `modules/nixos/desktop/steam.nix` | |

### Module layering

```
modules/
  nixos/core/       在所有NixOS主机中永久导入：用户配置、区域语言、硬件适配、桌面环境、虚拟化、网络组件
  nixos/desktop/    永久导入，由mySystem.desktop.enable控制生效：boot、GDM、env、Niri、GNOME、Distrobox、Steam
  nixos/hardware/   永久导入，由mySystem.hardware.enable控制生效：音频（PipeWire）、蓝牙、网络（iwd+NetworkManager）、MCU工具链、NVIDIA基础驱动（后者需显式开启）
  home-manager/     多用户共用配置，同时兼容 NixOS 与 macOS 系统
    cli/            通用加载项：Shell（Fish）、编辑器（Neovim）、开发工具、TUI终端交互工具
    gui/            仅用于桌面用户加载：应用程序（含嵌入式工具链）、备用主题、窗口管理器（Niri / Noctalia）、VSCode、Fcitx5输入法
  darwin/           macOS专属配置：系统默认设置、Homebrew图形化应用包
```

### `mkHomeManager` 样板代码

`flake.nix` 中定义了 `mkHomeManager` 函数，用于生成所有 NixOS 主机共用的 Home-Manager 集成配置块。带图形界面的主机传入参数 `extraModules = [ ./modules/home-manager/gui ]`；无图形服务器主机与 WSL 环境主机则不传入该参数。macOS 系统使用独立的内联 Home-Manager 配置块（不调用 `mkHomeManager`），原因是其需要通过 `lib.mkForce` 强制覆盖 NUR 软件源覆盖层，且共用模块的配置逻辑与 NixOS 不同。

### 各主机配置

| Host | System | Key features |
|------|--------|-------------|
| desktop | x86_64-linux | Niri WM, NVIDIA RTX 3060Ti, 4K@150Hz |
| laptop | x86_64-linux | GNOME, NVIDIA MX150 (legacy driver, PRIME offload), btrfs, TLP |
| wsl | x86_64-linux | CLI-only, WSL container |
| server | x86_64-linux | Stub, only nixosCore |
| macbook | aarch64-darwin | nix-darwin, Homebrew casks |

### 平台适配特殊处理

每条只写「是什么 + 根因 + 移除条件 + 详见何处」，不超过 3 行；细节放对应源码注释或 `docs/` 里。

- **国内清华镜像源**：二进制替换源与 nixpkgs 源码均使用 `mirrors.tuna.tsinghua.edu.cn`。若身处境外，下载速度会偏慢，可自行更换镜像。
- **Fish 4.8.0 覆盖补丁**：`modules/home-manager/default.nix` 对 Fish 打补丁，补全缺失的 `create_manpage_completions.py` 文件（对应 nixpkgs 工单 #535122）。待上游合并修复后即可移除该覆盖层。
- **XWayland 下的 Xft.dpi 补写**：fcitx5 在 XWayland 客户端上只读 X11 资源库的 `Xft.dpi` 决定候选窗缩放，而 xwayland-satellite 0.8.2 只把缩放写进 XSETTINGS（且未给 Xwayland 传 `-dpi`），导致微信等 X11 应用候选词停在 1.0x、比 VSCode 等 Wayland 应用小 `scale` 倍。`modules/nixos/desktop/niri/default.nix` 的 `xwayland-xft-dpi` wrapper 补写 `96 × scale` 并在 `startup.kdl` 自启。**TODO**：待 nixpkgs 的 xwayland-satellite 包含 PR #477（sync Xft.dpi through RESOURCE_MANAGER）后删除该 workaround。
- **NVIDIA 显存泄漏修复**：`modules/nixos/hardware/nvidia-base.nix` 配置 Niri 应用专属参数，限制空闲缓冲区池大小，规避显存泄漏问题。
- **显示器冷启动 EDID 自愈**：4K 屏断电再上电时 NVIDIA 读到合成 stub EDID（只剩 640x480，叠加 scale 1.5 后内容巨大），stub 校验和有效、连接器仍 connected，内核认为状态没变而不补发 hotplug。`hosts/desktop/edid-reprobe.nix` 的 udev 规则**监听显卡节点 `card1`**（DRM 的 hotplug uevent 全发在显卡节点，匹配连接器子设备 `card1-DP-2` 永远收不到）、发现目标模式缺失即 `echo detect > status` 强制真实重读 EDID。`drm.edid_firmware` 与 `video=` 两路已排除（会黑屏）。完整根因、重试次数与升级手段见该文件头部注释。
- **STM32Cube 固件仓库路径**：CubeMX 默认把约 500MB 固件包下到 `~/STM32Cube/Repository`，路径记在非托管的 `~/.stm32cubemx/plugins/updater/updater.ini`。已收拢到 `~/Apps/STM32Cube/Repository`，由 `modules/home-manager/gui/apps/embedded.nix` 每次切换钉住该行（ini 混着时间戳/窗口尺寸等可变状态，无法整体托管）。数据迁移需手动 `mv` 一次。
- **WinApps（Windows 应用接入桌面）**：libvirt 后端，接入层 `modules/home-manager/gui/winapps.nix`，装机盘 `pkgs/windows-vm-media`（xorriso 往上游 ISO 追加，不重打包）。**密码不进 nix store**：`RDP_ASKPASS` 读本机 `~/.config/winapps/rdp-pass`（0600）。探针走 libvirt `<hostdev>` 直通而非 RDP，模块提供 `winapps-usb attach/detach <vid:pid>`「谁用谁拿」。**完整手册见 `docs/winapps.md`**。
  - 两个已知坑：本地化 Windows 上 RDP 放行必须走 `WINAPPS-SETUP.bat`（上游按英文组名放行在中文系统必然失败）；直通期间设备**仍出现在 `lsusb` 里**，别拿它判断归属，看 `/dev/ttyUSB*` 或 `winapps-usb`。
- **客户机使用宿主代理**：mihomo 只监听 `127.0.0.1`，客户机直接指向 `192.168.122.1:<port>` 会 `Connection refused`。`modules/nixos/networking/proxy-vm.nix` 的 `libvirt-proxy-forward.service`（`mySystem.proxy.exposeToVms`，desktop/laptop 已开）在 `virbr0` 地址上 socat 转发到回环端口——只暴露给客户机网段，且不必用 route_localnet + nftables DNAT 那套（会把回环地址变成可路由地址）。客户机侧仍需一次性把 WinINET 与 `netsh winhttp` 都指向 `192.168.122.1:<port>`，见 `docs/winapps.md` §10.4 / §12.5。
- **输入法托盘图标**：fcitx5 只经 D-Bus 报图标名，图片由 Noctalia 按主题解析；MacTahoe 主题**自带** `status/24/fcitx-rime.svg` 且排在本层号之前，故只往 `hicolor` 放同名 SVG 无效。`modules/home-manager/gui/fcitx5.nix` 因此在与 `config.gtk.iconTheme.name` **同名**的目录下建薄覆盖层（`~/.local/share/icons/<主题>/scalable/apps/`，**绝对不能有 `index.theme`**——一旦有，GTK/Qt 会把它当整个主题的根，文件夹/文件类型/应用图标全回退 Adwaita）。字形取 HarmonyOS Sans SC 轮廓静态内联，靠 11% 留白控制视觉大小。详见 `docs/themes.md`「输入法托盘图标」。
- **自动升级固定走 flake**：`system.autoUpgrade.flake` 由 `networking.hostName` 推导出 `/home/mengw/Projects/nixos-config#<host>`。新增主机时 `networking.hostName` 必须与 flake 输出属性同名，否则 autoUpgrade 会找错目标。`allowReboot = false` 意味着内核更新后**不会自动重启**，需手动重启才能用上新内核。各主机的 flake 仓库统一位于 `/home/mengw/Projects/nixos-config`，若某主机仓库路径不同需覆盖该选项。
- **滚动升级的可追溯性**：`--refresh` 每日重写工作区的 `flake.lock`，而 Nix 对脏 git 树令 `self.rev = null`，`system.configurationRevision`（`flake.nix` 中显式声明）会退化为 `"dirty"`，代际就无法回溯 commit。因此 `nixos-upgrade.service` 的 `postStop` 在升级成功后以本人身份提交 `flake.lock`，保持工作区干净；另外 `.github/workflows/flake-check.yml` 的 `schedule` 触发每天 03:40 先把 nixpkgs 刷到 master HEAD 再求值所有主机，赶在 04:40 的 autoUpgrade 之前拦截上游回归（push/PR 触发只验已锁定的 `flake.lock`，看不到滚动通道的新提交）。

## 文档索引

`docs/` 放各子系统的深度说明（本文件只留结论、坑与轮廓）；动某个子系统前先读对应那篇，能省一轮反推。

| 改动主题 | 文档 | 对应代码 |
|------|------|------|
| Fish、环境变量、PATH | `docs/fish.md` | `modules/home-manager/cli/shell/fish.nix` |
| Foot 终端 | `docs/foot.md` | `modules/home-manager/gui/apps/foot.nix` |
| 输入法（Rime、候选窗、托盘图标） | `docs/input.md` + `docs/themes.md` | `modules/home-manager/gui/fcitx5.nix`、`modules/nixos/desktop/default.nix` |
| 桌面主题 / GTK / Qt / 图标 / 壁纸 | `docs/themes.md` | `modules/home-manager/gui/themes/default.nix`、`modules/home-manager/gui/wm/noctalia.nix` |
| Niri 快捷键、窗口与布局规则 | `docs/niri.md` | `modules/home-manager/gui/wm/config/` + 生成 KDL 的 `gui/wm/default.nix` |
| GNOME（laptop 的默认会话） | `docs/gnome.md` | `modules/nixos/desktop/gnome/default.nix` |
| 装了哪些应用 | `docs/softwares.md` | `modules/home-manager/gui/apps/`（含嵌入式工具链） |
| 开发工具链、Distrobox | `docs/environment.md` | `modules/home-manager/cli/dev` |
| tmux（含会话持久化） | `docs/tmux.md` | `modules/home-manager/cli/tools/tmux.nix` + `tests/tmux-persistence.sh` |
| WinApps / Windows 虚拟机 / 探针直通 | `docs/winapps.md` | `modules/home-manager/gui/winapps.nix`、`pkgs/windows-vm-media`、`modules/nixos/virtualization` |
| 部署、升级、垃圾回收 | `docs/manager.md` | 命令速查，与本文件「命令」节互为补充 |
