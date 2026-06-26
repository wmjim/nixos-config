{ lib, config, pkgs, ... }:
let
  cfg = config.mengw.desktop.common.fcitx5;
  commonCfg = config.mengw.desktop.common;
  desktopCfg = config.mengw.desktop;
in
{
  options.mengw.desktop.common.fcitx5.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "启用 Fcitx5 输入法（系统层面）";
  };

  config = lib.mkIf (cfg.enable && commonCfg.enable && desktopCfg.enable) {
    # 安装输入法引擎
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        # 设为 true：通过 compositor 的 Wayland 输入法协议工作
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
          fcitx5-mellow-themes
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
      XMODIFIERS = "@im=fcitx";
      # GTK/Qt 输入法模块 — 强制使用 fcitx5 直连而不是通过 Mutter 的 text-input 协议中转
      # NixOS fcitx5 模块在 waylandFrontend=true 时不会设置这些变量（它认为 wayland 下不需要）
      # 但 GNOME 下如果没有这些变量，GTK 不会走 fcitx5 IM 模块，光标坐标经 Mutter 转发后会偏移
      QT_IM_MODULE = "fcitx";
      SDL_IM_MODULE = "fcitx";
      # GLFW 程序没有自动探测输入法模块的机制，强制设置为 ibus 以启用输入法（fcitx5 兼容 ibus 协议）
      GLFW_IM_MODULE = "ibus";
      # 使 Electron 使用 Wayland 原生输入法，不经过 XWayland 转发，避免输入法候选框在 Electron 应用中显示异常的问题
      NIXOS_OZONE_WL = "1";
    };
  };
}
