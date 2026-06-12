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
        kdePackages.fcitx5-qt # 支持 Qt5/6 应用
        fcitx5-gtk # 支持 GTK3/4 应用
        # 输入法主题
        fcitx5-inflex-themes
        # fcitx5-rime 中文输入引擎 + 万象拼音词库
        (fcitx5-rime.override {
          rimeDataPkgs = [ pkgs.rime-wanxiang ];
        })
      ];
    };
  };

  # NixOS 新版本依赖 XDG Autostart 来启动输入法，启用此选项以确保输入法在登录时自动启动
  # 否则 fcitx5 有时不会自动启动
  services.xserver.desktopManager.runXdgAutostartIfNone = true;

  environment.sessionVariables = {
    # GTK3/GTK4/Tauri/Flutter 应用输入法模块
    GTK_IM_MODULE = "fcitx";
    # 传统 Qt 输入法变量(Qt5时代)，保持兼容
    # 优先加载 fcitx
    QT_IM_MODULE = "fcitx";
    # Qt 6.7+ 引入新机制
    # 先尝试 wayland，如果失败再尝试 fcitx
    QT_IM_MODULES = "wayland;fcitx";
    # 支持运行于 Xwayland 的其它软件
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    # GLFW 程序没有自动探测输入法模块的机制，强制设置为 ibus 以启用输入法（fcitx5 兼容 ibus 协议）
    GLFW_IM_MODULE = "ibus";
    # 使 Electron 使用 Wayland 原生输入法，不经过 XWayland 转发，避免输入法候选框在 Electron 应用中显示异常的问题
    NIXOS_OZONE_WL = "1";
  };
}
