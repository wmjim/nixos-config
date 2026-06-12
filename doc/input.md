# NixOS 在 Niri 桌面环境下配置 Fcitx5 中文输入

system 负责安装和环境变量，home manager 负责 Fcitx5 配置。

## system 配置

```nix
{ config, pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      # 支持 Wayland 
      waylandFrontend = true;
      addons = with pkgs; [
        # fcitx5 中文插件
        kdePackages.fcitx5-chinese-addons
        # fcitx5 配置工具
        kdePackages.fcitx5-configtool
        # fcitx5 输入法模块
        kdePackages.fcitx5-qt  # 支持 Qt5/6 应用
        fcitx5-gtk             # 支持 GTK3/4 应用
        # 输入法主题
        fcitx5-inflex-themes
        # fcitx5-rime 中文输入引擎 + 万象拼音词库
        (fcitx5-rime.override {
          rimeDataPkgs = [ pkgs.rime-wanxiang ];
        })
      ];
    };
  };
}
```

- `kdePackages.fcitx5-chinese-addons` 包含与中文相关的 addon（插件），如拼音、双拼和五笔。
- 对于 Qt5/6 程序，安装 `kdePackages.fcitx5-qt` 输入法模块
- 对于 GTK3/4 程序，安装 `fcitx5-gtk` 输入法模块
- 需要图形化管理 fcitx5 配置，安装`kdePackages.fcitx5-configtool`
- 输入法主题 ，仅代表个人审美，也可自行选择 [fcitx5-themes-github](https://github.com/topics/fcitx5-theme)，

> [!TIP] 为什么选择 kdePackages 包集而不是 qt6Packages
> 当前的 Nixpkgs Qt6 生态主入口正在逐步向 `kdePackages` 收敛。

> [!TIP] 万象拼音
> 万象拼音的使用还需要手动下载一个语法模型文件 `wanxiang-lts-zh-hans.gram`，从 [RIME-LMDG releases](https://github.com/amzxyz/RIME-LMDG/releases/tag/LTS) 下载，并将其放入 Fcitx5 的 Rime 用户目录（`~/.local/share/fcitx5/rime/`）

## 管理

```bash
# 查看 fcitx5 诊断
fcitx5-diagnose
```

- fcitx5 配置文件位于 `~/.config/fcitx5`