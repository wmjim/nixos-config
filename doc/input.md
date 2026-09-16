# Fcitx5 中文输入法

配置分两层：**system**（`modules/nixos/desktop/default.nix`）负责安装与环境变量；**home-manager**（`modules/home-manager/gui/fcitx5.nix`）负责 Rime 用户配置。

## system 配置

- 输入法框架：fcitx5（`waylandFrontend = true`）
- 插件：
  - `kdePackages.fcitx5-chinese-addons`：拼音、双拼、五笔等中文插件
  - `kdePackages.fcitx5-configtool`：图形化配置工具
  - `kdePackages.fcitx5-qt`：Qt5/6 应用输入法模块
  - `fcitx5-gtk`：GTK3/4 应用输入法模块
  - `fcitx5-mellow-themes`：输入法主题
  - `fcitx5-rime`（+ 万象拼音词库 `rime-wanxiang`）：Rime 输入引擎

## 环境变量

XWayland 应用仍依赖传统输入法环境变量，已手动补齐：

```nix
XMODIFIERS = "@im=fcitx";
GTK_IM_MODULE = "fcitx";
QT_IM_MODULE = "fcitx";
SDL_IM_MODULE = "fcitx";
GLFW_IM_MODULE = "fcitx";
```

## XWayland 候选窗缩放（workaround）

fcitx5 的候选窗按“输入上下文所属显示”选后端渲染：原生 Wayland 客户端走 WaylandUI
（跟随合成器分数缩放），XWayland 客户端走 XCBUI，而 XCBUI 的缩放 = `DPI / 96`，
DPI 只取自 X11 的 `Xft.dpi` 资源（RESOURCE_MANAGER）。xwayland-satellite 0.8.2
只把缩放发布在 XSETTINGS 的 `Xft/DPI`（fcitx5 读 XSETTINGS 时只取
`Net/IconThemeName`），且未给 Xwayland 传 `-dpi`，于是微信/QQ 等 XWayland 应用里
候选词停在 1.0x，比 VSCode 等 Wayland 应用小 `scale` 倍。

当前由 `modules/nixos/desktop/niri/default.nix` 的 `xwayland-xft-dpi` wrapper 补写
`Xft.dpi = 96 × scale`（desktop → 144，laptop → 120）到资源库，并在
`startup.kdl` 中随 niri 自启；fcitx5 监听 RESOURCE_MANAGER 变化并立即重读，
无需重启输入法。验证：

```bash
xrdb -query                     # 应显示 Xft.dpi:<TAB>144
displays=$(fcitx5-diagnose | grep -c 'Group \[x11::0\]')   # 微信等 X11 客户端所在分组
```

> [!TODO] 上游已修复
> xwayland-satellite PR #477（`feat: sync Xft.dpi through RESOURCE_MANAGER`，
> 2026-09-08 合并，关闭 issue #301）在 master 中做了同样的同步。待 nixpkgs 内的
> xwayland-satellite 版本 > 0.8.2 后，删除该 workaround（wrapper + `startup.kdl` 自启项）。

## Rime 用户配置

`~/.local/share/fcitx5/rime/default.custom.yaml`：

```yaml
patch:
  __include: wanxiang_suggested_default:/
  __patch:
    menu/page_size: 7
```

- 使用万象拼音的推荐默认配置，候选词每页 7 个。

> [!TIP] 万象拼音语法模型
> 需手动下载语法模型文件 `wanxiang-lts-zh-hans.gram`，从
> [RIME-LMDG releases](https://github.com/amzxyz/RIME-LMDG/releases/tag/LTS) 下载，
> 放入 `~/.local/share/fcitx5/rime/` 目录。

## 管理

```bash
# 查看 fcitx5 诊断信息
fcitx5-diagnose
```

- fcitx5 配置目录：`~/.config/fcitx5`
- Niri 下已在 `startup.kdl` 中自启 fcitx5；XWayland 应用输入法由 `GTK_IM_MODULE` 等变量接管

## 构建缓存失效

Rime 按 mtime 判断构建缓存是否过期，而 nix store 内文件 mtime 恒为 0。因此
`rime-wanxiang` 的数据包路径发生变化时（例如更新 nixpkgs），Rime 会重建词典
却沿用旧 schema，导致输入法**静默失效**：进程在、schema 在，却打不出候选词。

该情况已在 `modules/home-manager/gui/fcitx5.nix` 中自动处理：以 rime 数据源
路径作为指纹，指纹变化时清理 `build/`（仅派生缓存，用户词典 `*.userdb`、
`*.gram`、`sync/` 均保留）。指纹记录在 `~/.local/share/fcitx5/.rime-data-key`。

需要手动补救时：

```bash
rm -rf ~/.local/share/fcitx5/rime/build
```

排查时优先看日志（fcitx5 自动启动，stderr 会进 journal）：

```bash
journalctl --user | grep org.fcitx
```

> [!NOTE]
> `lua_gears.cc` 的 `attempt to call a nil value` 报错在输入法正常时也会大量
> 出现（约 3 万条/天），不能作为故障判据。`fcitx5-diagnose` 的插件列表也不
> 可靠——它可能完全不含 Rime，而 Rime 实际是加载的。
