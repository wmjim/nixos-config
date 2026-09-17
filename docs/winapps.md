# WinApps 使用教程（libvirt 后端）

在 Niri/GNOME 桌面上把 Windows 虚拟机里的程序当**原生窗口**使用（FreeRDP RemoteApp），
典型用途：Keil MDK、仅 Windows 可用的串口/烧录工具、Office。

- 方案与取舍的来龙去脉见 [`CLAUDE.md`](../CLAUDE.md) 的「WinApps」条目。
- 本文是**操作手册**：从零建 VM 到日常使用、加应用、接单片机探针、排错。

---

## 0. TL;DR

```bash
# 一次性（系统侧，已由仓库配置完成）
sudo nixos-rebuild switch --flake ~/Projects/nixos-config#desktop

# 一次性（Windows 侧）：建 VM → 装 Win11 Pro → 运行装机盘里的 WINAPPS-SETUP.bat → 重启
# 一次性（Linux 侧）：填 Windows 账户密码，然后扫描并生成应用入口
printf '%s' '你的Windows账户密码' > ~/.config/winapps/rdp-pass && chmod 600 ~/.config/winapps/rdp-pass
winapps-setup --user

# 日常
winapps UV4          # 单个应用 = 一个独立窗口
winapps windows      # 需要整机桌面时
winapps help         # 其余子命令
```

> 密码不是 PIN。Windows 登录界面上敲的 6 位 PIN 对 RDP **无效**，必须是账户**密码**
> （设置 → 账户 → 登录选项 → 「密码」那一栏对应的东西）。

---

## 1. 架构与文件索引

```
┌───────────────────────── Linux（NixOS + Niri/GNOME）─────────────────────────┐
│  启动器 / 终端                                                                │
│      │  winapps UV4                                                          │
│      ▼                                                                       │
│   FreeRDP 3（RemoteApp：/app:program:"C:\Keil_v5\UV4\UV4.exe"）              │
│      │  TCP 3389（走 virbr0，自动绕过 http_proxy：no_proxy 含 192.168.0.0/16）│
│      ▼                                                                       │
│   libvirtd（qemu:///system）                                                  │
│   ┌───────────────── VM: RDPWindows ─────────────────┐                       │
│   │ TermService :3389                                │                       │
│   │ 防火墙：装机盘 WINAPPS-SETUP.bat 按“语言无关”方式放行 ← 关键             │
│   │ UV4.exe 等 → 在 Linux 上是独立窗口（图标/剪贴板/声音/麦克风）             │
│   └──────────────────────────────────────────────────┘                       │
│   ~/.config/winapps/winapps.conf   ← home-manager 托管（勿手改）              │
│   ~/.config/winapps/rdp-pass       ← 唯一不托管的输入，0600，手动维护         │
└──────────────────────────────────────────────────────────────────────────────┘
```

| 文件 | 职责 |
| --- | --- |
| `flake.nix` / `flake.lock` | `winapps` 输入：只提供 `winapps` / `winapps-launcher` 两个**包**（上游没有 NixOS/HM 模块） |
| `modules/nixos/virtualization/default.nix` | libvirtd / qemu_kvm / swtpm / virtiofsd + 装机盘 `windowsVmMedia` |
| `pkgs/windows-vm-media/` | 装机盘 ISO 的构建：上游 virtio-win ISO + 上游 `oem/` + 本仓库的 `WINAPPS-SETUP.bat` / `winapps-fix-rdp.ps1` |
| `modules/home-manager/gui/winapps.nix` | 接入层：包、`winapps.conf`、askpass 脚本、密码缺失提示、`RDP_SCALE` 派生 |
| `~/.config/winapps/winapps.conf` | 运行时配置，由 home-manager 生成（改配置改 Nix，勿手改） |
| `~/.config/winapps/rdp-pass` | Windows 账户密码，**手动维护**（不进 nix store） |

---

## 2. 前置条件

| 项 | 要求 |
| --- | --- |
| 虚拟化 | CPU 支持 VT-x/AMD-V，`mySystem.virtualization.enable = true`（desktop/laptop 已开） |
| 宿主磁盘 | VM 磁盘 + 10GB 余量；本机 VM 磁盘为 qcow2，落在 `/var/lib/libvirt/images` |
| Windows 镜像 | **Windows 11 Pro / Enterprise**（RemoteApp 需要 RDP 服务端，Home 版不行） |
| Windows 账户 | 必须**设置了密码**（空密码账户无法 RDP 登录） |
| 代理（可选） | 若在墙内：Clash 设 `allow-lan`，guest 里把代理指向 `192.168.122.1:7897`（见 §10.4） |

---

## 3. 一次性系统配置（已由仓库完成）

```nix
mySystem.virtualization.enable = true;   # hosts/<host>/default.nix 已设
```

它带来的东西：

| 配置项 | 作用 |
| --- | --- |
| `virtualisation.libvirtd.qemu.swtpm.enable` | Windows 11 要求的 TPM 2.0 |
| nixpkgs 默认携带的 OVMF | UEFI + Secure Boot 固件（`/run/libvirt/nix-ovmf/`） |
| `qemu.vhostUserPackages = [ virtiofsd ]` | 主机目录共享（virtiofs）所需 |
| `environment.systemPackages` 里的 `windowsVmMedia` | 装机盘：`/run/current-system/sw/share/windows-vm-media/windows-vm-media.iso` |
| HM `mengw.gui.winapps` | `winapps`、`winapps-launcher`、`LIBVIRT_DEFAULT_URI=qemu:///system`、`winapps.conf`、askpass |

装机盘内容（一张盘搞定装机与配置）：

```
windows-vm-media.iso
├── amd64\w11 …            # virtio-win 驱动（上游 ISO 原样）
├── virtio-win-guest-tools.exe
├── README-WinApps.txt     # 盘内步骤说明
├── WINAPPS-SETUP.bat      # ★ 唯一入口：上游 oem\install.bat + 语言无关的 RDP 放行
├── winapps-fix-rdp.ps1    #   ↑ 被上面调用的脚本（组资源 ID → 端口反查 → 显式规则 三级兜底）
└── oem\                   # 上游脚本原样：install.bat / RDPApps.reg / TimeSync.ps1 / NetProfileCleanup.ps1
```

> **为什么需要 `WINAPPS-SETUP.bat`**：上游 `oem\install.bat` 用
> `Enable-NetFirewallRule -DisplayGroup 'Remote Desktop'` 放行端口，而该组名在中文
> Windows 上是「远程桌面」，英文名匹配不到、`netsh` 兜底同样认本地化组名 → 规则永远
> 是禁用状态，3389 被防火墙 DROP（症状：`netstat` 里有 `0.0.0.0:3389 LISTENING`，但从
> 宿主机连不上、连接超时）。本仓库的脚本改成按**组资源 ID**（`@FirewallAPI.dll,-28752`）
> 和**端口号**定位规则，完全不依赖语言。

---

## 4. 创建 Windows 虚拟机（virt-manager）

打开 `virt-manager`（`qemu:///system`），新建虚拟机：

| 步骤 | 选择 |
| --- | --- |
| 安装来源 | 本地安装介质 → 选 Windows 11 ISO（勾选「自动从安装介质检测」） |
| 内存 / CPU | 建议 ≥ 8192 MiB / 4 vCPU（本机配了 16 GiB / 8 vCPU） |
| 存储 | 建议 ≥ 64 GB（本机 128 GB 级即可；qcow2 稀疏分配，按需增长） |
| 名称 | **必须与 `mengw.gui.winapps.vmName` 一致**，默认 `RDPWindows` |
| 勾选 | 「在安装前自定义配置」 |

在「自定义配置」里确认/补齐：

1. **Overview** → 芯片组（Chipset）= **Q35**；固件 = **UEFI x86_64 ... secure**（提供 Secure Boot）
2. **Add Hardware → TPM**：类型 **CRB**、版本 **2.0**（Windows 11 硬性要求）
3. **Add Hardware → Storage**：`Device type = CDROM device`，选装机盘
   `/run/current-system/sw/share/windows-vm-media/windows-vm-media.iso`
4. 网卡 / 磁盘二选一：
   - **省事路线（本机采用）**：磁盘 `SATA`、网卡 `e1000e` → **装系统时不需要任何驱动**，
     装完直接用；
   - **性能路线**：磁盘 `virtio`、网卡 `virtio` → 安装时点「加载驱动程序」，指向装机盘
     `amd64\w11` 目录。
5. （可选）**Boot Options** → 勾「主机启动时启动虚拟机」。非必须：WinApps 在应用启动时
   会自动 `virsh start`。

热插/更换光驱注意：**SATA 不支持热插拔**。运行中要换盘必须用 USB 总线：

```bash
export LIBVIRT_DEFAULT_URI=qemu:///system   # 登录 shell 已由 HM 设好，脚本里需显式
cat > /tmp/cd.xml <<'EOF'
<disk type='file' device='cdrom'>
  <driver name='qemu' type='raw'/>
  <source file='/path/to/iso'/>
  <target dev='sdc' bus='usb'/>
  <readonly/>
</disk>
EOF
virsh attach-device RDPWindows /tmp/cd.xml --live --config   # 加盘
virsh detach-disk  RDPWindows sdc --live --config            # 拔盘
```

---

## 5. 安装 Windows 11 Pro

1. 按向导安装，版本选 **Pro**（Home 没有 RDP 服务端，RemoteApp 无从谈起）。
2. 账户：建议**本地账户**并**设置密码**（记牢，后面要写进 `rdp-pass`）。
   若走到联网/登录微软账户那步无法跳过：`Shift+F10` 打开命令行 → `OOBE\BYPASSNRO`（新版镜像可能已移除）。最省事的做法是让 VM 联网
   （e1000e 免驱）正常走完，然后**新建一个带密码的本地账户**用于 RDP 亦可。
3. 进入桌面后（如果用了 virtio 路线）：运行装机盘根目录 `virtio-win-guest-tools.exe`
   补齐驱动与 guest agent；SATA/e1000e 路线下它是可选（装了会顺带得到 QEMU guest agent、
   balloon 驱动，方便以后切 virtio）。

装完先确认网络正常（`ipconfig` 能拿到 `192.168.122.x`）。

---

## 6. Windows 侧收尾：一张盘、一个入口

在 Windows 里打开装机盘（盘符视情况，如 `E:`）→ **右键 `WINAPPS-SETUP.bat` → 以管理员身份运行**。

它做两件事：

1. 调用上游 `oem\install.bat`：导入 `RDPApps.reg`（打开 RDP、要求 NLA、**关闭 RemoteApp
   程序白名单**、键盘布局、关掉 snap bar 等）、创建 `TimeSync` / `NetProfileCleanup` 计划任务。
   *这一步里「放行防火墙」那句在中文系统上必然失败（见 §3 的说明），属预期。*
2. 跑 `winapps-fix-rdp.ps1`：**真正把 3389 放行**（三级兜底），并打印自检信息。

成功的标志（脚本最后会打印）：

```
  TermService = Running
  TCP    0.0.0.0:3389    0.0.0.0:0    LISTENING    <pid>
Expect: TCP 0.0.0.0:3389 LISTENING
```

然后**重启 Windows**。之后在宿主机上验一次：

```bash
timeout 5 bash -c 'echo > /dev/tcp/192.168.122.21/3389' && echo "RDP OPEN" || echo "RDP CLOSED"
virsh -c qemu:///system domifaddr RDPWindows     # 确认 IP（DHCP 会变，脚本按 VM 名自动解析）
```

---

## 7. Linux 侧接入

### 7.1 写入 Windows 密码（唯一不托管的输入）

```bash
printf '%s' '你的Windows账户密码' > ~/.config/winapps/rdp-pass && chmod 600 ~/.config/winapps/rdp-pass
```

`winapps.conf` 里配的是 `RDP_ASKPASS`，FreeRDP 通过
`~/.local/bin/winapps-askpass` 读这个文件，因此密码不会出现在命令行/日志里，也不会进
nix store。文件缺失时每次 `nixos-rebuild switch` 会打印提示。

### 7.2 扫描并生成应用入口

```bash
winapps-setup --user
```

它按下表顺序走一遍（每一步失败都带退出码，见 §12）：

```
1 安装向导标题
2 [WARNING] ... located outside of default location ...      ← Nix 包路径，正常
3 读配置 / 依赖 / 组 / VM 状态 / 3389 端口 / RDP 连通性测试
4 扫描 Windows 已装程序（会自动 tsdiscon 断开 RDP 会话）
5 创建 Windows 桌面入口 + 应用选择菜单（见下）
6 INSTALLATION COMPLETE
```

第 5 步会依次弹**两个菜单**，文案与建议：

**菜单 1 —— `How would you like to handle officially supported applications?`**

| 选项 | 含义 | 建议 |
| --- | --- | --- |
| `Set up all detected officially supported applications` | 为**已存在**的官方支持程序建条目（Office/Adobe/VS/`cmd`/`explorer`/`mspaint`…） | 图省事可选，不会产生垃圾条目 |
| `Choose specific officially supported applications to set up` | 复选框挑选 | **推荐**：勾 `explorer`（文件管理窗口）、`cmd`（命令行窗口） |
| `Skip setting up any officially supported applications` | 全部跳过 | 只想要 Keil 时也可以 |

**菜单 2 —— `How would you like to handle other detected applications?`**

| 选项 | 含义 | 建议 |
| --- | --- | --- |
| `Set up all detected applications` | 注册表里检测到的**所有** exe 都建条目 | ❌ 会把启动器塞满系统组件 |
| `Select which applications to set up` | 复选框挑选 | ✅ **选这个**，只勾你要的（如 Keil 的 `UV4`） |
| `Do not set up any applications` | 全部跳过 | 以后用 `--add-apps` 再补 |

> 第二个菜单的列表来自扫注册表（卸载项 + `App Paths\*` + UWP + choco/scoop），
> **Keil 只会出现在这里**（exe 名为 `UV4.exe`）。
> 操作：`dialog` 的复选框 —— **空格**勾选、方向键移动、**Tab** 到 `<Ok>`、**Enter** 确认。

---

## 8. 日常使用

```bash
winapps help                        # 全部子命令
winapps UV4                         # 单个应用 → 一个独立窗口（短名 = exe 文件名，不带扩展名）
winapps UV4 ~/Projects/foo.uvprojx  # 顺带用该应用打开文件
winapps windows                     # 整机 Windows 桌面（装 pack、看许可弹窗时用）
winapps manual 'C:\path\app.exe'   # 临时用任意 exe 起一个 RemoteApp，不建条目（不写条目、直接给 exe 路径）
winapps killrdp                     # 杀掉所有 FreeRDP 会话
winapps cleanrdp                    # 清理孤儿进程跟踪文件
```

- 图形入口：应用菜单/启动器里搜 Windows 程序名（`µVision`、`文件资源管理器`…），
  图标是从 Windows 的 exe 里抠出来的。
- 手动整机会话（WinApps 出问题时的兜底，`pkgs.freerdp` 已装到 PATH）：

  ```bash
  xfreerdp /v:192.168.122.21 /u:mengw /cert:tofu /dynamic-resolution /sound /clipboard
  wlfreerdp …    # 同上，Wayland 原生客户端
  ```
- **VM 无需手动启动**：`winapps <app>` 会自动 `virsh start`；VM 已运行则直接连。
- 单会话特性：**RDP 会话会接管其控制台会话**，所以用 WinApps 时 virt-manager 里的控制台
  会变成锁屏 —— 这是 Windows 客户端 SKU 的正常行为，不是故障。

### 8.1 文件互通（摩擦最小的是这三种，**没有拖拽**）

| 方式 | 说明 |
| --- | --- |
| 剪贴板 | 文本双向直接可用；**文件**也支持（FreeRDP 剪贴板文件通道默认开）：Linux 文件管理器 `Ctrl+C` → Windows `Ctrl+V` |
| `\\tsclient\home` | 整个宿主 `~` 映射进 Windows（`RDP_FLAGS` 里的 `+home-drive`） |
| `\\tsclient\proj` | 额外共享盘（`RDP_FLAGS` 里的 `/drive:proj,/home/mengw/Projects`，可用 `mengw.gui.winapps.extraDrives` 增删） |
| 拖拽文件 | ❌ RDP 协议不支持（SPICE 侧也是实验性），别指望 |

### 8.2 高 DPI 与缩放

`RDP_SCALE` 只接受 `100`/`140`/`180`；本仓库按 `mySystem.desktop.scale` 自动取值
（1.5 倍屏 → `140`）。若文字偏大/偏小，改 `mengw.gui.winapps.rdpScale` 后 `nixos-rebuild switch`。

---

## 9. 新增或更新应用清单

装完新 Windows 程序（例如 Keil 之后又装了 VS Code）后：

```bash
winapps-setup --user --add-apps     # 增量：只扫描并把新应用加进来，不动已有条目
```

其他 `winapps-setup` 参数（`winapps-setup --help`）：

| 参数 | 用途 |
| --- | --- |
| `--user` / `--system` | 装到 `~`（默认，免 sudo）/ 装到 `/usr` |
| `--setupAllOfficiallySupportedApps` | 跳过菜单，直接给所有官方支持应用建条目 |
| `--add-apps` | 只加新应用 |
| `--uninstall` | 卸载 WinApps 的脚本与桌面条目（不删 VM） |

---

## 10. 单片机开发（Keil + 探针 + 串口）

### 10.1 探针直通（ST-Link / J-Link / CMSIS-DAP）

**USB 设备不进 RDP，而是用 libvirt `<hostdev>` 直通给客户机**（原生 USB 语义，bulk 传输稳定）：

```bash
export LIBVIRT_DEFAULT_URI=qemu:///system
cat > /tmp/stlink.xml <<'EOF'
<hostdev mode='subsystem' type='usb' managed='yes'>
  <source>
    <vendor id='0x0483'/>   <!-- ST-Link；J-Link 用 0x1366，CMSIS-DAP 用 0x0d28 -->
    <product id='0x374e'/>  <!-- 按 lsusb 实际值改 -->
  </source>
</hostdev>
EOF
virsh attach-device RDPWindows /tmp/stlink.xml --live   # 临时（本次运行）
virsh detach-device RDPWindows /tmp/stlink.xml --live   # 用完还给 Linux
```

- 也可在 virt-manager → Add Hardware → **USB Host Device** 里常驻。
- 设备 ID：`lsusb`；宿主的 udev 规则（`mySystem.hardware.mcu.enable`）已把探针节点授权给
  `users` 组，Linux 侧工具（`st-flash`/`openocd`/`probe-rs`）不受影响。
- **同一根探针不可能同时给 Linux 和 Windows**。频繁来回切最省心的做法：再买一根便宜探针
  专供 VM。
- `No more available PCI slots` 报错 = virt-manager 建的 `pcie-root-port` 用光了，删几个空的
  root port 再加设备。

### 10.2 串口（UART 监视）

μVision 没有实用的 COM 口终端，**建议把 USB-UART（CH340/CP2102…）留在 Linux**
（`tio` / `picocom` / `espflash monitor`），只把 SWD 探针给 Windows。
若用带 VCP 的 ST-Link V2-1/V3（Nucleo/Discovery 板载），直通该设备可一次拿到 SWD + COM。

### 10.3 RemoteApp 下的操作习惯

- RemoteApp 是**单窗口**，装 pack、看许可弹窗、首次配置这类「多窗口/模态」操作，
  用 `winapps windows` 进整机桌面更顺；日常编码再回 `winapps UV4`。
- 每个应用 = 一个独立 RDP 会话；关窗不断 VM。

### 10.4 让 Windows 侧能上网（下载 Keil DFP / 许可校验）

guest 里把系统代理指向宿主的 Clash（需在 Clash 里开 `allow-lan`）：

```
地址 192.168.122.1   端口 7897    （= mySystem.proxy.port，可在配置里改）
```

宿主自身的 RDP 流量会自动绕过代理（`no_proxy` 里含 `192.168.0.0/16`），不必额外配置。

---

## 11. 配置项速查

### 11.1 home-manager（`modules/home-manager/gui/winapps.nix`）

| 选项 | 默认 | 说明 |
| --- | --- | --- |
| `mengw.gui.winapps.enable` | `true` | 总开关（desktop/laptop 的 gui 模块内） |
| `mengw.gui.winapps.vmName` | `"RDPWindows"` | 必须与 `virsh list` 中的名字一致 |
| `mengw.gui.winapps.windowsUser` | `"mengw"` | Windows 账户名（**不是**计算机名，也不是显示名） |
| `mengw.gui.winapps.extraDrives` | `[ proj → ~/Projects ]` | 额外暴露给 Windows 的目录（`\\tsclient\<name>`） |
| `rdpScale` | 由 `mySystem.desktop.scale` 派生 | 100 / 140 / 180 |

生成的 `~/.config/winapps/winapps.conf`（示例，实际由 Nix 渲染）：

```conf
RDP_USER="mengw"
RDP_ASKPASS="/home/mengw/.local/bin/winapps-askpass"
WAFLAVOR="libvirt"
VM_NAME="RDPWindows"
RDP_SCALE="140"
RDP_FLAGS="/cert:tofu /sound /microphone +home-drive /drive:proj,/home/mengw/Projects"
DEBUG="true"
```

想改默认行为（例如加 `/network:lan`、开 `AUTOPAUSE="on"`、`DEBUG="false"`、`HIDEF="off"`），
改这个模块后 `nixos-rebuild switch`。

### 11.2 NixOS（`modules/nixos/virtualization/default.nix`）

| 配置 | 说明 |
| --- | --- |
| `mySystem.virtualization.enable` | libvirtd + qemu_kvm + swtpm + spice USB 重定向 + `virbr0` 信任 |
| `qemu.vhostUserPackages = [ virtiofsd ]` | 建 virtiofs 共享时需要 |
| `environment.systemPackages` 含装机盘 | 不再新建 VM 后，可把这行删掉省 ~840MB |

---

## 12. 排错

### 12.1 `winapps-setup` 退出码

| 码 | 常量 | 含义 |
| --- | --- | --- |
| 1 | `EC_FAILED_CD` | 进入源码目录失败 |
| 4 | `EC_NO_CONFIG` | 缺 `winapps.conf` |
| 5 | `EC_MISSING_DEPS` | 依赖缺失（应不会发生：包已 wrap） |
| 7 | `EC_NOT_IN_GROUP` | 用户不在 `libvirtd`/`kvm` 组 |
| 8/9/10 | `EC_VM_OFF`/`PAUSED`/`ABSENT` | VM 未启动 / 已暂停 / 不存在（查 `vmName`） |
| 12 | `EC_NO_IP` | 客户机没拿到 IP |
| 13 | `EC_BAD_PORT` | 3389 不可达 → **§12.2** |
| 14 | `EC_RDP_FAIL` | 凭据/协议失败 → **§12.3** |
| 15 | `EC_APPQUERY_FAIL` | 查询已装程序失败 |

> `winapps` 运行时是另一套退出码（如 `EC_UNSUPPORTED_APP=14` 表示该短名没有条目，
> 见 `bin/winapps` 顶部）。

### 12.2 端口不通（3389 CLOSED）

```bash
virsh -c qemu:///system domifaddr RDPWindows                       # IP 是否变化
timeout 5 bash -c 'echo > /dev/tcp/<IP>/3389' && echo OPEN || echo CLOSED
```

| 症状 | 原因 / 处理 |
| --- | --- |
| 连接**超时**（6s 无响应） | 防火墙 DROP：在 Windows 里重跑装机盘的 `WINAPPS-SETUP.bat`（管理员），或确认其第三步兜底是否命中 |
| 秒拒（RST） | 没有监听者：`fDenyTSConnections` 仍为 1（重启 Windows）或装的是 **Home** 版（`winver` 确认，Home 无 RDP 服务端） |
| 监听正常但仍不通 | 网络配置文件是「公用」——脚本已自带 `-Profile Any` 规则覆盖；必要时在 Windows 里 `Set-NetConnectionProfile -NetworkCategory Private` |

### 12.3 RDP 认证失败（`ERRCONNECT_LOGON_FAILURE`）

日志位置：`~/.local/share/winapps/FreeRDP_Test_*.log`。先在宿主机独立验证凭据：

```bash
F=xfreerdp      # 来自 pkgs.freerdp（HM 的 winapps 模块顺带装的）
IP=$(virsh -c qemu:///system domifaddr RDPWindows | awk 'NR==3{print $4}' | cut -d/ -f1)
FREERDP_ASKPASS=~/.local/bin/winapps-askpass "$F" +auth-only /v:"$IP" /u:mengw /d: /cert:tofu
```

| 现象 | 处理 |
| --- | --- |
| `LOGON_FAILURE` | 用户名或密码错。用户名用 `whoami`（Windows 里）确认，**不是**显示名；密码必须是账户密码而非 PIN |
| 证书警告 `CERTIFICATE NAME MISMATCH` / `host key changed` | 自签名证书的正常提示（CN=计算机名），`/cert:tofu` 已自动接受；想清缓存：`rm -rf ~/.config/freerdp/server` |
| Kerberos `default realm` 报错 | 干扰信息，无需处理（FreeRDP 随后回退 NTLM） |

### 12.4 应用启动异常

```bash
winapps cleanrdp          # 清孤儿状态文件后重试
winapps killrdp
sed -n '1,80p' ~/.local/share/winapps/winapps.log   # DEBUG="true" 时的运行日志
```

---

## 13. 调试技巧（本轮实操总结）

```bash
export LIBVIRT_DEFAULT_URI=qemu:///system

# 1) 直接看客户机屏幕（不用开图形控制台，图片可当证据存档）
virsh screenshot RDPWindows /tmp/vm.png

# 2) 往客户机注入按键（HMP 支持和弦；libvirt 的 send-key 对某些键名支持不全）
virsh qemu-monitor-command RDPWindows --hmp "sendkey meta_l-r"   # Win+R
virsh qemu-monitor-command RDPWindows --hmp "sendkey ret"        # 回车
virsh qemu-monitor-command RDPWindows --hmp "sendkey ctrl-spc"   # 关中文输入法（否则 whoami 会变「五毫米」）

# 3) DHCP/网卡视角
virsh net-dhcp-leases default
virsh domifaddr RDPWindows

# 4) 客户机内部诊断（注入打开 cmd 后截图读取）
#    whoami / net user / net user <user> / net localgroup administrators / netstat -ano | findstr :3389
```

---

## 14. 维护者备忘

### 14.1 装机盘的组成与构建

```
上游 virtio-win ISO（pkgs.virtio-win.src）
        │  xorriso -map 追加（而非对解包目录重打包：那样会因 -R/-J 双份目录记录膨胀到 1.5GB）
        ▼
windows-vm-media.iso（837MB）= 驱动 + oem/（按 inputs.winapps.rev 固定抓取）+ 本仓库两个脚本
```

- `oem/` 的 4 个文件用 `fetchurl` + 固定 hash 抓取：上游 flake 的 `nix-filter` 未收录
  `oem/`，store 里没有这些文件。**升级 `winapps` 输入后**若上游改了 oem 内容，构建会因
  哈希失配而**显式失败**（这是有意的）——此时更新 `pkgs/windows-vm-media/default.nix`
  里的 hash 即可。
- `WINAPPS-SETUP.bat` 在仓库里按 LF 存，构盘时用 `sed` 转 CRLF（cmd.exe 解析带括号的
  if/else 块依赖 CRLF）。
- 脚本分支回归：4 个 mock 桩场景（①组 ID 命中 ②组名匹配失败改走端口反查 ③无任何规则→新建显式规则 ④`deny=1` 且无监听→重启 TermService），用
  `nix shell nixpkgs#powershell -c pwsh -File <用例>.ps1 -Scenario <n>` 跑。用例文件未入库，需要时补进
  `pkgs/windows-vm-media/test/` 并接进 `.github/workflows` 即可。

### 14.2 升级 WinApps 版本

```bash
nix flake update winapps      # 或 nix flake lock --update-input winapps
nixos-rebuild switch --flake ~/Projects/nixos-config#desktop
```

`pkgs/windows-vm-media` 的 oem hash 若失配按 §14.1 更新；`winapps-setup` 的交互文案
若变化，同步本文 §7.2。

### 14.3 卸载 / 清理

```bash
winapps-setup --user --uninstall          # 删脚本与桌面条目（保留 VM 与配置目录）
rm -r ~/.config/winapps ~/.local/share/winapps ~/Windows
virsh -c qemu:///system undefine --remove-all-storage RDPWindows   # 删 VM 及其磁盘
# 不再需要装机盘：从 modules/nixos/virtualization/default.nix 的 systemPackages 里删掉 windowsVmMedia
```

---

## 附：一条真实故障的完整复盘（2026-09）

| 现象 | 排查 | 结论 |
| --- | --- | --- |
| `winapps-setup` 报 `EC_BAD_PORT`（3389 不可达） | `nc` 三个端口全超时（DROP 而非 RST）→ 截图看客户机防火墙规则状态 | 网络配置文件是「公用」+ 内置规则 `[False]`，上游那句按英文组名启用失败（**语言本地化 bug**） |
| 用显式 `-Profile Any` 规则后端口 OPEN，但 `EC_RDP_FAIL` | 读 `FreeRDP_Test_*.log` → `nla_recv_pdu: ERRCONNECT_LOGON_FAILURE` | 认证失败：`rdp-pass` 里填的不是账户密码（客户机里 `whoami` = `mengw\mengw` 证明用户名正确） |
| 修好密码后一切正常 | `winapps-setup --user` 扫描并生成条目 | —— |

上述两点修复都已固化：防火墙修法进了装机盘（§3/§6），凭据要求写进本文 §0/§12.3。
