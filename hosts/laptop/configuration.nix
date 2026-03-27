# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/nixos/desktop.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.canTouchEfiVariables = true;

  # 开启自动升级
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # 垃圾回收配置
  # 自动执行垃圾回收，每周运行一次，删除7天前的旧数据
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections with iwd (impala TUI).
  # Enable iwd as a systemd service
  systemd.services.iwd = {
    enable = true;
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.iwd}/libexec/iwd";
      Restart = "on-failure";
    };
  };

  # 打开 flakes
  # nix.settings = {
  #   experimental-features = [ "nix-command" "flakes" ];
  #   # 并行下载优化
  #   connect-timeout = 5;             # 连接超时时间
  #   # 二进制缓存配置（加速包下载）
  #   substituters = [
  #     # 1. 首选清华镜像
  #     "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
  #     # 2. 备选：中科大镜像
  #     "https://mirrors.ustc.edu.cn/nix-channels/store"
  #     # 3. 最后是官方和社区源（保底）
  #     "https://nix-community.cachix.org"  # Nix Community 缓存
  #     "https://cache.nixos.org"           # NixOS 主缓存服务器
  #   ];
  #   # 信任二进制缓存
  #   trusted-public-keys = [
  #     "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkj5bg+wLbWLCTCfOj2Wc="
  #     "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
  #   ];
  # };

  # 引入 home-manager
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.mengw = import ../../home/default.nix;

  # 启用硬件加速
  hardware.graphics.enable = true;

  # 时区:上海
  time.timeZone = "Asia/Shanghai";

  # Configure network proxy if necessary
  # networking.proxy.default = "https://127.0.0.1:7897";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "zh_CN.UTF-8";

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  # 启用 KVM 硬件虚拟化（libvirtd 已包含 QEMU 支持）
  virtualisation.libvirtd.enable = true;
  # 开启终端串口（让虚拟机直接输出到当前终端，核心！）
  boot.kernelParams = [ "console=ttyS0" ];

  # 字体配置
  fonts.packages = with pkgs; [
    # Maple Mono 字体（中英文等宽字体）
    maple-mono.NF
    maple-mono.NF-CN

    # 中文字体
    lxgw-wenkai-screen        # 优美的楷体，适合阅读正文

    # 英文字体
    source-serif-pro          # 经典的衬线体    

    # Emoji 字体
    noto-fonts-color-emoji  
  ];

  fonts.fontconfig.defaultFonts = {
    # 衬线体 (Serif)：阅读长文章最舒服的组合
    # 英文 Source Serif -> 中文霞鹜文楷 -> 备用思源宋体
    serif = [ "Source Serif Pro" "LXGW WenKai Screen" ];
    # 无衬线体 (Sans-Serif)：清晰现代，适合系统菜单和网页
    # 英文 Noto Sans -> 中文思源黑体
    sansSerif = [ ];
    # 等宽字体 (Monospace)：针对 C++ 代码和终端优化
    # Maple Mono 提供了非常漂亮的连字和中文对齐
    monospace = [ "Maple Mono NF" ];
    # emoji 图形化的标签
    emoji = [ "Noto Color Emoji" ];
  };

  # 优化渲染设置（让字体更锐利）
  fonts.fontconfig.subpixel.lcdfilter = "default";
  fonts.fontconfig.hinting.autohint = true;

  # 禁用 systemd 的自动挂起，合盖不休眠
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";              # 普通状态合盖
    HandleLidSwitchDocked = "ignore";        # 外接显示屏合盖
    HandleLidSwitchExternalPower = "ignore"; # 插电状态合盖
  };



  # 兼容 FHS 
  programs.nix-ld.enable = true;

  # 光标主题
  environment.variables = {
    XCURSOR_THEME = "Adwaita";
  };


  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };
  services.dbus.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mengw = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "input" "network" "libvirtd" "kvm" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
   
    ];
  };
  programs.fish.enable = true;

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    iwd
    tlp
 ];

  nixpkgs.config = {
    allowUnfree = true;   # 允许所有 unfree 包
  };

  programs.nixvim = {
    enable = true;
    version.enableNixpkgsReleaseCheck = false;
    colorschemes.catppuccin.enable = true;
    plugins.lualine.enable = true;
    defaultEditor = true;
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # Open ports in the firewall.
  # nixos 默认启用防火墙，需要允许放行22端口
  networking.firewall.allowedTCPPorts = [ 22 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}

