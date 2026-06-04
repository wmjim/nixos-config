# NixOS 基础配置（所有 NixOS 主机共享）
{ config
, pkgs
, lib
, inputs
, ...
}:

{
  # Boot
  boot.loader.systemd-boot.enable = true; # 启用 systemd-boot 引导加载器
  boot.loader.systemd-boot.configurationLimit = 10; # 最多保留 10 个配置
  boot.loader.efi.canTouchEfiVariables = true; # 允许修改 EFI 变量
  boot.kernelPackages = pkgs.linuxPackages_latest; # 最新内核

  # 开机自动升级
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  # 垃圾回收配置
  # 自动垃圾回收，每周执行一次，删除 7 天前的垃圾
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Nix 配置
  nix.settings = {
    # 启用 Flakes 特性以及配套的新 nix 命令行工具
    experimental-features = [
      "flakes"
      "nix-command"
    ];
    connect-timeout = 5;
    # 自动存储优化，定期优化存储以节省空间
    auto-optimise-store = true;
    substituters = [
      # 1. 首选清华镜像
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      # 2. 备选：中科大镜像
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      # 3. 保底：最后是官方和社区镜像
      # "https://nix-community.cachix.org"
      # "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkj5bg+wLbWLCTCfOj2Wc="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    # 添加当前用户为 trusted user
    trusted-users = [
      "root"
      "mengw"
    ];
  };

  # 硬件加速（所有硬件 NixOS 主机通用）
  hardware.graphics.enable = true;

  # FHS 兼容
  programs.nix-ld.enable = true;

  # 系统总线（所有 NixOS 主机都需要）
  services.dbus = {
    enable = true;
    implementation = "broker";
  };

  # 允许非自由软件
  nixpkgs.config.allowUnfree = true;

  # 允许不安全的包（闭源应用的旧依赖）
  nixpkgs.config.permittedInsecurePackages = [
    "openssl-1.1.1w"
  ];


  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };

  # 键盘布局
  services.xserver.xkb = {
    layout = "us";
    options = "caps:escape";
  };

  # 防火墙：默认启用，需放行 22 端口
  networking.firewall.allowedTCPPorts = [ 22 ];

  # 系统级包
  environment.systemPackages = with pkgs; [
    iwd
    git
    wget
  ];

  system.stateVersion = "26.05";
}
