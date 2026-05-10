# niri 窗口管理器配置（搭配 Noctalia Shell）
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./noctalia.nix
    ../apps.nix
  ];

  # niri 合成器
  programs.niri.enable = true;

  # 登录管理器：greetd + tuigreet → 启动 niri
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd niri-session";
        user = "greeter";
      };
    };
  };

  # 触控板
  services.libinput.enable = true;

  # Polkit + 密钥环（图形会话需要）
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # XDG portal（Wayland 屏幕共享、文件选择器等）
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
    config.niri = {
      default = [ "gnome" "gtk" ];
    };
  };

  # Wayland / niri 环境变量
  environment.sessionVariables = {
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    CLASH_VERGE_ALLOW_CLIPBOARD = "1";
    RUST_BACKTRACE = "1";
    GTK_THEME = "Orchis-Purple";
    GTK_ICON_THEME = "WhiteSur";
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };

  # niri 周边工具和主题
  environment.systemPackages = with pkgs; [
    # --- niri 周边 ---
    xwayland-satellite        # x11 应用
    swaylock-effects          # 锁屏
    swayidle                  # 空闲触发
    wl-clipboard              # 剪贴板
    cliphist                  # 剪贴板历史
    grim slurp                # 截图
    wf-recorder               # 屏幕录制
    brightnessctl             # 亮度控制
    playerctl                 # 媒体控制
    pamixer                   # 音量控制
    networkmanagerapplet      # 网络托盘
    pavucontrol               # 音量 GUI
    fuzzel                    # 应用启动器
    walker                    # 快捷键/命令搜索（中文输入法兼容）
  ];

  # RDP 远程桌面端口
  networking.firewall.allowedTCPPorts = [ 3389 ];
}
