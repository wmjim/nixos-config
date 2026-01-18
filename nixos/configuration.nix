# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # 多核并行构建优化
    max-jobs = 8;                    # 自动检测所有逻辑核心数
    cores = 8;                       # 一次构建过程中并发任务的最大数量

    # 构建沙箱（安全性和隔离性）
    sandbox = true;

    # 构建优化
    auto-optimise-store = true;      # 自动优化存储

    # 并行下载优化
    connect-timeout = 5;             # 连接超时时间

    # 二进制缓存配置（加速包下载）
    substituters = [
      "https://nix-community.cachix.org"  # Nix Community 缓存
      "https://cache.nixos.org"           # NixOS 主缓存服务器
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkj5bg+wLbWLCTCfOj2Wc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };

  # 禁用 systemd 的自动挂起，合盖不休眠
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";              # 普通状态合盖
    HandleLidSwitchDocked = "ignore";        # 外接显示屏合盖
    HandleLidSwitchExternalPower = "ignore"; # 插电状态合盖
  };

  


  # 垃圾回收配置
  # 自动执行垃圾回收，每周运行一次，删除7天前的旧数据
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  # networking.hostName = "nixos"; # Define your hostname.

  # Configure network connections interactively with nmcli or nmtui.
  # networking.networkmanager.enable = true;
  networking.wireless.iwd = {
    enable = true;
  };

  # 启用硬件加速
  hardware.graphics.enable = true;
  
  # Set your time zone.
  time.timeZone = "Asia/Shanghai";

  # 兼容 FHS 
  programs.nix-ld.enable = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://127.0.0.1:7897";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "zh_CN.UTF-8";
  # console = {
  #  font = "MapleMono-NF-CN--Regular.ttf";
  #  keyMap = "us";
  #  useXkbConfig = true; # use xkb.options in tty.
  # };

  # 字体配置
  fonts.packages = with pkgs; [
    # Maple Mono 字体（中英文等宽字体）
    maple-mono.NF-CN-unhinted
    maple-mono.truetype

    # 中文字体
    noto-fonts-cjk-sans       # 思源黑体
    noto-fonts-cjk-serif      # 思源宋体

    # 英文字体
    noto-fonts                # Noto 字体家族
    liberation_ttf            # Liberation 字体

    # Emoji 字体
    noto-fonts-color-emoji    # 彩色 Emoji（已包含 noto-fonts-emoji）
  ];

  fonts.fontconfig.defaultFonts = {
    serif = [ "Noto Serif CJK SC" "Noto Serif" ];
    sansSerif = [ "Noto Sans CJK SC" "Noto Sans" ];
    monospace = [ "Maple Mono NF CN" ];
    emoji = [ "Noto Color Emoji" ];
  };

  # 光标主题
  environment.variables = {
    XCURSOR_THEME = "Adwaita";
  };

  # 启用图形系统（wayland）
  services.xserver.enable = true;
  # 排除 xterm
  services.xserver.excludePackages = with pkgs; [ xterm ];
  # 启用基本图形支持，让系统提供 hyprland
  programs.hyprland.enable = true;

  # 启用 greetd（极简登录管理器）
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd Hyprland";
        user = "mengw";
      };
    };
  };

  boot.kernel.sysctl = {
    # 网络转发
    "net.ipv4.ip_forward" = 1;

    # 网络性能优化
    "net.core.default_qdisc" = "fq";           # 使用公平队列调度器
    "net.ipv4.tcp_congestion_control" = "bbr";  # 使用 BBR 拥塞控制算法
    "net.ipv4.tcp_fastopen" = 3;               # 启用 TCP Fast Open

    # 网络缓冲区优化
    "net.core.rmem_max" = 16777216;            # 最大接收缓冲区 (16MB)
    "net.core.wmem_max" = 16777216;            # 最大发送缓冲区 (16MB)
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";  # TCP 接收缓冲区
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";  # TCP 发送缓冲区

    # 文件系统优化
    "fs.file-max" = 2097152;                   # 增加文件描述符限制
    "fs.inotify.max_user_watches" = 524288;    # 增加文件监视数量

    # 内存管理优化
    "vm.swappiness" = 10;                      # 降低 swap 使用倾向
    "vm.dirty_ratio" = 15;                     # 脏页比例达到 15% 时开始写入
    "vm.dirty_background_ratio" = 5;           # 后台脏页写入比例

    # 安全性优化
    "net.ipv4.conf.all.rp_filter" = 1;         # 启用反向路径过滤
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;  # 忽略 ICMP 广播
    "net.ipv4.conf.all.accept_source_route" = 0;  # 禁止源路由
    "net.ipv6.conf.all.accept_source_route" = 0;
  };
  # networking.firewall.enable = false;

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mengw = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "input" "network" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.fish;
    packages = with pkgs; [
    ];
  };
  programs.fish.enable = true;
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [
    wget
    openssh
    sshfs
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # 开启 openssh 守护进程
  services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;  # 临时启用密码登录用于测试
        PermitRootLogin = "no";         # 禁止 root 登录
        X11Forwarding = true;
      };
      # SFTP 子系统配置
      extraConfig = ''
        # SFTP 子系统
        Subsystem sftp internal-sftp

        # SFTP 日志（用于调试）
        LogLevel VERBOSE
      '';
  };
  # Open ports in the firewall.
  # nixos 默认启用防火墙，需要允许放行22端口
  networking.firewall.allowedTCPPorts = [ 22 ];
  
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

