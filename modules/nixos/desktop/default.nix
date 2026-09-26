# 桌面环境系统级模块（GDM、环境变量、窗口管理器）
# 仅在 mySystem.desktop.enable = true 时生效
{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.mySystem.desktop;
in
{
  options.mySystem.desktop.niri.enable = lib.mkEnableOption "Niri 窗口管理器";
  options.mySystem.desktop.gnome.enable = lib.mkEnableOption "GNOME 桌面环境";

  # 显示器逻辑缩放（GNOME/Niri 的 fractional scaling 值，如 4K 屏的 1.5）。
  # AWT 的 sun.java2d.uiScale 只接受整数，此处统一声明桌面缩放，
  # 由 env.nix 向上取整后喂给 JVM，避免各处重复推导或硬编码无效值。
  # 默认从下方 monitors 首项派生（单一数据源），主机可显式覆盖。
  options.mySystem.desktop.scale = lib.mkOption {
    type = lib.types.numbers.positive;
    default = 1;
    description = "显示器逻辑缩放（分数缩放值，如 1.5）；AWT 应用会向上取整为整数 uiScale";
  };

  # 显示器声明：主机数据，驱动 niri outputs.kdl 生成与 Noctalia 的 DDC 亮度
  # （消费方见 modules/home-manager/gui/wm/）。此前 wm 模块按 hostName switch
  # 硬编码两台主机的输出，新增/换显示器要改共享模块；现在数据留在 hosts/。
  options.mySystem.desktop.monitors = lib.mkOption {
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.str;
            description = "niri 物理输出名（如 DP-2 / eDP-1）";
          };
          mode = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "3840x2160@150.000";
            description = "分辨率与刷新率；null 则由 niri 自动选择";
          };
          scale = lib.mkOption {
            type = lib.types.numbers.positive;
            default = 1;
            description = "此输出的逻辑缩放";
          };
          position = lib.mkOption {
            type = lib.types.nullOr (
              lib.types.submodule {
                options = {
                  x = lib.mkOption {
                    type = lib.types.int;
                    default = 0;
                  };
                  y = lib.mkOption {
                    type = lib.types.int;
                    default = 0;
                  };
                };
              }
            );
            default = null;
            description = "输出位置；null 则由 niri 自动排列";
          };
          focus = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "niri 启动时聚焦此输出（多输出主机只应有一台开启）";
          };
          ddc = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "此显示器走 DDC/CI 调亮度（需硬件支持且主机已开 hardware.i2c；内屏 eDP 走 sysfs backlight，勿开）";
          };
        };
      }
    );
    default = [ ];
    description = "显示器声明（按主机）：niri 输出配置与 Noctalia DDC 亮度的数据源";
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
    # 逻辑缩放从主显示器（monitors 首项）派生：env.nix 的 AWT/xcursor 推导与
    # niri 的 per-output scale 共用同一数据源，主机不再两处声明（可显式覆盖）
    mySystem.desktop.scale = lib.mkDefault (
      if cfg.monitors == [ ] then 1 else (lib.head cfg.monitors).scale
    );

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
          # fcitx5-mellow-themes 已移除：候选词窗主题改用 catppuccin-fcitx5
          # 的 Frappe + mauve 变体（与终端/编辑器同家族），主题包及选择
          # 集中在 modules/home-manager/gui/fcitx5.nix，不再留无人选用的主题包。
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
      # adwaita-qt 已移除：它只提供一个 Qt5 样式插件（plugins/styles/adwaita.so），
      # 而 Qt 侧已改用 Kvantum + MacTahoe（见 modules/home-manager/gui/themes）。
      # Wayland 的窗口装饰来自 qadwaitadecorations（由 HM 的 qt.platformTheme 提供），
      # 与这个包无关，不受影响。
      papirus-icon-theme
      bibata-cursors
    ];
  };
}
