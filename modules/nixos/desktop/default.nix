# 桌面环境系统级模块（GDM、环境变量、窗口管理器）
# 仅在 mySystem.desktop.enable = true 时生效
{ lib, config, pkgs, ... }:
let
  cfg = config.mySystem.desktop;
in
{
  options.mySystem.desktop.niri.enable = lib.mkEnableOption "Niri 窗口管理器";
  options.mySystem.desktop.gnome.enable = lib.mkEnableOption "GNOME 桌面环境";

  # 显示器逻辑缩放（GNOME/Niri 的 fractional scaling 值，如 4K 屏的 1.5）。
  # AWT 的 sun.java2d.uiScale 只接受整数，此处统一声明桌面缩放，
  # 由 env.nix 向上取整后喂给 JVM，避免各处重复推导或硬编码无效值。
  options.mySystem.desktop.scale = lib.mkOption {
    type = lib.types.numbers.positive;
    default = 1;
    description = "显示器逻辑缩放（分数缩放值，如 1.5）；AWT 应用会向上取整为整数 uiScale";
  };

  imports = [
    ./boot.nix
    ./gdm.nix
    ./env.nix
    ./niri
    ./gnome
    ./distrobox.nix
    ./steam.nix
  ];

  config = lib.mkIf cfg.enable {
    # gvfs：文件管理、回收站、网络共享
    services.gvfs.enable = true;

    # 输入法（系统层面）
    i18n.inputMethod = {
      enable = true;
      type = "fcitx5";
      fcitx5 = {
        waylandFrontend = true;
        addons = with pkgs; [
          kdePackages.fcitx5-chinese-addons
          kdePackages.fcitx5-configtool
          kdePackages.fcitx5-qt
          fcitx5-gtk
          fcitx5-mellow-themes
          (fcitx5-rime.override {
            rimeDataPkgs = [ pkgs.rime-wanxiang ];
          })
        ];
      };
    };

    # 确保 fcitx5 在登录时自动启动
    services.xserver.desktopManager.runXdgAutostartIfNone = true;

    # 输入法环境变量
    # 注意：nixpkgs 的 fcitx5 模块在 waylandFrontend=true 时不设置
    # GTK_IM_MODULE/QT_IM_MODULE（原生 Wayland 应用走 zwp_input_method_v2），
    # 但 XWayland 应用仍依赖这些变量，因此在此处手动补齐。
    environment.sessionVariables = {
      XMODIFIERS = "@im=fcitx";
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "fcitx";
      NIXOS_OZONE_WL = "1";
    };

    # GTK/Qt 主题包
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      gtk4
      gnome-themes-extra
      adwaita-qt
      papirus-icon-theme
      bibata-cursors
    ];
  };
}
